import ballerina/http;
import ballerina/io;

// this is a main function which executes and terminates
// as different from the use of keyword service resource in hello-service
// returns a tainted error
public function main() returns @tainted error? {
    // Connects to the hello service
    http:Client helloClient = new("http://localhost:9090/hello");
    // Call the hello service endpoint '/sayHello'
    http:Response helloResp = check helloClient->get("/sayHello");

    // print the payload if not error (short hand magic via the check keyword)
    io:println(check helloResp.getTextPayload());
}