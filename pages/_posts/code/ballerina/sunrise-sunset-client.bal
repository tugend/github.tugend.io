import ballerina/http;
import ballerina/io;

public function main() returns @tainted error? {
    http:Client sunriseApi = new ("http://api.sunrise-sunset.org");

    http:Response sunriseResp = check sunriseApi->get("/json?lat=6.9349969&lng=79.8538463");

    json sunrisePayload = check sunriseResp.getJsonPayload();
    io:println(sunrisePayload);
}
