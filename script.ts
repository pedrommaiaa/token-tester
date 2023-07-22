// Native
import * as fs from "fs";
import { exec, execSync } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

const maxConcurrency = 3;
let currentConcurrency = 0;

// Function cache
const functionCacheFile = "functionCache.json";
let functionCache: { [key: string]: string };

if (fs.existsSync(functionCacheFile)) {
    functionCache = JSON.parse(fs.readFileSync(functionCacheFile, "utf8"));
  } else {
    functionCache = {};
    fs.writeFileSync(functionCacheFile, JSON.stringify(functionCache));
  }
  

// Task Queue
let tasksQueue: (() => Promise<void>)[] = []

// Task Runner
const runTask = async () => {
    if (tasksQueue.length > 0 && currentConcurrency < maxConcurrency) {
        currentConcurrency++;
        const task = tasksQueue.shift();
        if (task) {
            await task();
            currentConcurrency--;
            runTask();
        }
    }
};

// Add Task
const addTask = (task: () => Promise<void>) => {
    tasksQueue.push(task);
    runTask();
};

const main = (functionSelector0x: string, amountOfTokens: string, tokenNamesCsv: string) => {
    // Split the token names into an array, using comma delimiter
    const tokenNames = tokenNamesCsv.split(",");
    tokenNames.pop();

    // Check that the number of tokens matches the number of token names
    if (tokenNames.length !== parseInt(amountOfTokens)) {
        console.error("Error: The number of tokens does not match the number of token names");
        process.exit(1);
    }

    // Parse additional input
    const amountOfTokensNum = Number(amountOfTokens.slice(2));
    const functionSelector = functionSelector0x.slice(2).replace(/0+$/, "");

    // Search for the human-readable function name from the foundry out/ ABI
    let functionName = functionCache[functionSelector];

    if (!functionName) {
        functionName = execSync(
            `grep -r "${functionSelector}" out | grep "test" | cut -d: -f2 | cut -d\\" -f2 | cut -d\\( -f1`
        )
        .toString()
        .trim();

        functionCache[functionSelector] = functionName;
        fs.writeFileSync(functionCacheFile, JSON.stringify(functionCache, null, 2));
    }

    const reportFile = "reports/TOKENS_REPORT.md";

    // Create a writable stream to the report file
    const writeStream = fs.createWriteStream(reportFile, { flags: "a" });

    // If the file was just created, write the header row
    fs.stat(reportFile, (err, stats) => {
        if (err || !stats.size) {
            writeStream.write("| TestName | TokenName | Result |\n| -------- | --------- | ------ |\n")
        }
    });

    // Create task list
    const tasks: Promise<any>[] = [];

    // Use a for loop based on range 1..$AMOUNT_OF_TOKENS
    for (let i = 1; i <= amountOfTokensNum; i++) {
        addTask(async () => {
            try {
                await execAsync(`FORGE_TOKEN_TESTER_ID=${i} forge test --mt "${functionName}" --silent --ffi`);
                    writeStream.write(`| ${functionName} | ${tokenNames[i-1]} | ✅ |\n`);
                } catch (error) {
                    writeStream.write(`| ${functionName} | ${tokenNames[i-1]} | ❌ |\n`);
                }
            });
    }

    // Also, instead of using Promise.allSettled(), you need to set up a loop to check if all tasks have finished:
    const checkAllTasksFinished = setInterval(() => {
        if (tasksQueue.length === 0 && currentConcurrency === 0) {
            clearInterval(checkAllTasksFinished);
            // End the stream to ensure all data is flushed to the file
            writeStream.end();
        }
    }, 100);
};

const args = process.argv.slice(2);

if (args.length != 3) {
    console.error(`Error: Please supply the correct parameters.`);
    process.exit(1);
}

main(args[0], args[1], args[2]);

// NOTE: Testing command
// node dist/script.js "0x7258935200000000000000000000000000000000000000000000000000000000" "0x01" "BaseERC20,"