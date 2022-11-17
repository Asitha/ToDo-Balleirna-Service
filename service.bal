import ballerina/http;
import ballerina/uuid;

type Task record {|
    string id;
    string task;
|};

type AddTaskRequest record {
    string description;
};

map<Task> activeTasks = {};

# A service representing a network-accessible API
# bound to port `9090`.
service /todo on new http:Listener(9090) {

    resource function get tasks() returns json|error {
        return {tasks: activeTasks.toArray()};
    }

    resource function post tasks(@http:Payload AddTaskRequest req) returns record {|*http:Created;|}|error {
        string nextId = uuid:createType1AsString();
        activeTasks[nextId] = {id: nextId, task: req.description};
        return {};
    }

    resource function delete tasks(string id) returns record {|*http:Ok;|}|error {
        _ = activeTasks.remove(id);
        return {};
    }

}
