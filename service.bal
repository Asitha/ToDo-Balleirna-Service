import ballerina/http;
import ballerina/uuid;

type Task record {|
    string id;
    string description;
|};

type AddTaskRequest record {
    string description;
};

map<Task> activeTasks = {};

# A service representing a network-accessible API
# bound to port `9090`.
#
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /todo on new http:Listener(9090) {

    resource function get tasks() returns json|error {
        return {tasks: activeTasks.toArray()};
    }

    resource function post tasks(@http:Payload AddTaskRequest req) returns record {|*http:Created;|}|error {
        string nextId = uuid:createType1AsString();
        activeTasks[nextId] = {id: nextId, description: req.description};
        return {};
    }

    resource function delete tasks(string id) returns record {|*http:Ok;|}|error {
        _ = activeTasks.remove(id);
        return {};
    }
}
