require("dotenv").config({ path: require("path").resolve(__dirname, "../.env") });
const mongoose = require("mongoose");

// Debug: Print environment variables to check if they are loaded
 console.log("MONGO_USER:", process.env.MONGO_USER);
 console.log("MONGO_PASS:", process.env.MONGO_PASS ? "****" : "Not set"); // Hide password
 console.log("MONGO_HOST:", process.env.MONGO_HOST);
 console.log("MONGO_DB_NAME:", process.env.MONGO_DB_NAME);


// Check if required environment variables are set
if (!process.env.MONGO_USER || !process.env.MONGO_PASS || !process.env.MONGO_HOST || !process.env.MONGO_DB_NAME) {
    console.error("❌ Missing required environment variables! Check your .env file.");
    process.exit(1);
}

// Construct MongoDB URI
const uri = `mongodb+srv://${process.env.MONGO_USER}:${encodeURIComponent(process.env.MONGO_PASS)}@${process.env.MONGO_HOST}/${process.env.MONGO_DB_NAME}?retryWrites=true&w=majority&appName=Cluster0`;

console.log("MongoDB URI:", uri);

async function connectDB() {
    try {
        await mongoose.connect(uri);

        console.log("✅ Connected to MongoDB successfully using Mongoose!");
    } catch (error) {
        console.error("❌ MongoDB connection failed:", error);
        process.exit(1);
    }
}

// connectDB();

module.exports = connectDB;
