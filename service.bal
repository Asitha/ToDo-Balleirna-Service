import ballerina/http;
import ballerina/uuid;

import ballerina/sql;
import ballerinax/mysql;
import ballerina/log;
import ballerinax/mysql.driver as _;

configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;

type Task record {|
    string id;
    string description;
|};

type AddTaskRequest record {
    string description;
};

type Result record {|
    string result;
|};

mysql:Client mysqlClient = check new (host = dbHost,
user = dbUser, password = dbPassword, database = dbName, port = dbPort);

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

        stream<Task, sql:Error?> resultStream = mysqlClient->query(`SELECT id,description FROM tasks`);
        Task[] taskArray = [];
        check from var result in resultStream
            where result is Task
            do {
                taskArray.push(result);
            };
        return {tasks: taskArray};
    }

    resource function post tasks(@http:Payload AddTaskRequest req) returns record {|*http:Created;|}|error {
        string nextId = uuid:createType1AsString();
        sql:ExecutionResult|sql:Error res = mysqlClient->execute(`INSERT INTO tasks (id, description) VALUES (${nextId}, ${req.description})`);
        if (res is sql:Error) {
            log:printError("Error storing task", res);
            return error(string `Failed to add task with description ${req.description}`);
        }
        return {};
    }

    resource function delete tasks(string id) returns record {|*http:Ok;|}|error {
        sql:ExecutionResult|sql:Error res = mysqlClient->execute(`DELETE FROM tasks WHERE id=${id}`);
        if (res is sql:Error) {
            log:printError("Error deleiting task", res);
            return error(string `Failed to delete task with id ${id}`);
        }
        return {};
    }
}
