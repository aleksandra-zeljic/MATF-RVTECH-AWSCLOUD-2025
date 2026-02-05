const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const TABLE_NAME = process.env.CHARGERS_TABLE || "Chargers";

const DYNAMODB_ENDPOINT = process.env.LOCALSTACK_HOSTNAME
  ? `http://${process.env.LOCALSTACK_HOSTNAME}:4566`
  : "http://localhost:4566";

const client = new DynamoDBClient({
  endpoint: DYNAMODB_ENDPOINT,
  region: "us-east-1",
});

const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async () => {
  try {
    await docClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          chargerId: "1",
          town: "Beograd",
        },
      })
    );

    return {
      statusCode: 200,
      body: JSON.stringify({ ok: true }),
    };
  } catch (err) {
    console.error("DynamoDB put error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message || "Internal Server Error" }),
    };
  }
};
  