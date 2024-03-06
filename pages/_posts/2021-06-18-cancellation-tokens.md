---
title: Cancellation Tokens
category: "HTTP Services" 
tags: async csharp dotnet
---

`System.Threading` expose an elegant model for 'coordinating the canceling of
asynchronous operations'. It's basic use is as simple as shown in the following
snippet.

```csharp
/// <summary>
/// Fetch payment given <paymentid>, will throw TaskCanceledException if
/// the operation takes langer than the given time.
/// </summary>
public async Task<Payment> QueryPayment(Guid paymentId, int timeoutInMilliseconds)
{
    // Setup a source that cancels after <timeout>
    using var source = new CancellationTokenSource(Timespan.FromMilliseconds(timeoutInMilliseconds));

    return await _repo.query(paymentId, source.Token);
}
```

A lot of libraries, including `System.Threading.Tasks.Task` operations, take a
cancellation token and handles the cancellation for you. It's also possible to
handle it yourself using the methods `<IsCancellationRequested>` and
`<ThrowIfCancellationRequested>`, just make sure to clean up anything before you
return.

Further more; .Net controllers take an optional source token parameter  by
default , which will cancel if the caller prematurely close the connection. It
seems to me that this is an often overlooked feature, which can be used to great
benefit in an API to reduce resource consumption and improve performance!

It applies, of course, only for endpoints that can be cancelled, e.g. read-only
operations.

```csharp
[HttpGet("{paymentId:guid}")]
public async Task<IActionResult> GetPayment(Guid paymentId, CancellationToken token)
{
    // Warning: potentially very slow and expensive operation.
    var rating = await repo.QueryCreditRating(paymentId, cancellationToken);

    return Ok(new { Rating = rating.value });
}
```

### Additional notes

* TaskCanceledException, which is thrown from most Task operations when the
  token requests cancellation, derives from the more generally used
  OperationCanceledException.

* Multiple source warn the developer to be cautious of the \point of no
  cancellation\, i.e. you will not always be able to uncritically shut down an
  operation.

* It's advised to make sure your cancellation token source is disposed when
  you're done using it, since the garbage collector will often be slow in doing
  it for you, e.g. by using the `using` keyword.

  ```csharp
  public async Task<Payment> GetPayment(Guid paymentId)
  {
    using var source = new CancellationTokenSource(TimeSpan.FromMilliseconds(100));
    var result = await repo.Query(..., source);
    return new Payment(...);
  }
  ```

* If you would like to look into how to hook up a global handle of
  OperationCancelledExceptions, for example to map them automatically to a HTTP
  response if they bubble up to the controller layer, have a look at `Andrew
  Locks` blog in the sources below.

### Code Examples and Extracts

* [CancellationTokenTests](https://github.com/tugend/CodeSamples/blob/master/CancellationTokenSamples/Tests/CancellationTokenTests.cs):
  A simple example of using CancellationTokens to manage competing queries

  ```csharp
  [Fact]
  public async Task RacingQueries()
  {
      // ARRANGE
      var userId = Guid.NewGuid();
      var repo = new PaymentRepository();
      using var source = new CancellationTokenSource();

      // Start two competing queries
      var racingQuery1 = repo.QueryByUserId(userId, source.Token);
      var racingQuery2 = repo.QueryByUserId(userId, source.Token);

      // the first task to complete is assigned <winner>, the other is assigned <looser>
      var winner = await Task.WhenAny(racingQuery1, racingQuery2);
      var looser = new[] {racingQuery1, racingQuery2}.Single(x => x != winner);

      // ACT
      // when we have found a winner, we cancel any still running tasks if any
      source.Cancel();

      // ASSERT

      // Winner completed successfully
      Assert.True(winner.IsCompleted);
      Assert.True(winner.IsCompletedSuccessfully);

      // Looser completed by cancellation
      Assert.True(looser.IsCompleted);
      Assert.True(looser.IsCanceled);

      // Winner was not cancelled
      Assert.False(winner.IsCanceled);

      // None where faulted
      Assert.False(winner.IsFaulted);
      Assert.False(looser.IsFaulted);
  }
  ```

* [AdaptivePaymentRepositoryTests](https://github.com/tugend/CodeSamples/blob/master/CancellationTokenSamples/Tests/AdaptivePaymentRepositoryTests.cs):
  An implementation of a repository that use cancellation tokens to gracefully
  degrade to the best possible service given a dynamic limit of execution
  time, i.e. it returns a more detailed result if it has the computation time.

  ```csharp
    /// <summary>
    /// Assume we have plenty of processor power but suffer from periodic slow reads.
    /// To introduce a gradual degradation of service rather than risk downtime,
    /// we could try to have a two tier read operation that fetch both the slow and
    /// the fast data, and return the most detailed information we have within
    /// the given timeout.
    /// </summary>
    public async Task<Payment> QueryPayment(Guid paymentId, CancellationToken token)
    {
        // Start two tasks that both reference the expiring cancellation token
        var shallowDetailedPaymentTask = _shallowPaymentRepository.QueryByUserId(paymentId, token);
        var detailedPaymentTask = _detailedPaymentRepository.QueryByUserId(paymentId, token);

        try
        {
            var shallowPayment = await shallowDetailedPaymentTask;
            try
            {
                // Yes! This user is going to be real happy,
                // we can show him all the details we have on the payment
                // without exceeding the given time!
                return Payment.FromDetailedSource(shallowPayment, await detailedPaymentTask);
            }
            catch (OperationCanceledException)
            {
                // Haha, we didn't have time to fetch all the details but we got the basis content.
                return Payment.FromShallowSource(shallowPayment);
            }
        }
        catch (OperationCanceledException)
        {
            // Haha, we didn't have time to fetch all the details but we got the basis content.
            throw new OperationCanceledException("Sorry, we didn't manage to get any results in time!");
        }
    }
    ```

* [WebAPITests](https://github.com/tugend/CodeSamples/blob/master/CancellationTokenSamples/Tests/WebApiTests.cs):
  An API controller implementation that show how using
  cancellation tokens can improve performance in an API where requests share a
  limited resource pool.

### Sources

* [System.Threading.CancellationTokenSource documentation](https://docs.microsoft.com/en-us/dotnet/api/system.threading.cancellationtokensource?view=net-5.0)

* [Using CancellationTokens in ASP.NET Core MVC controllers 2017 ~ Andrew Lock](https://andrewlock.net/using-cancellationtokens-in-asp-net-core-mvc-controllers/)

* [Recommended patterns for CancellationToken 2014 ~ Andrew Arnott](https://devblogs.microsoft.com/premier-developer/recommended-patterns-for-cancellationtoken/)