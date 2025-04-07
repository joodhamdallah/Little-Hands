require("dotenv").config(); // Load environment variables
const express = require("express");
const mongoose = require("mongoose"); // Import mongoose to close connection properly
const connectDB = require("./database/connection"); // Import database connection
const userRoutes = require("./routes/userRoutes"); 

const app = express();
const port = process.env.PORT || 3000; // Use environment variable for port

// Middleware
app.use(express.json()); // Parse JSON requests

// Routes (Import and use API routes)
app.use('/public', express.static('public'));
app.use('/api', userRoutes); 

// Connect to DB & Start Server
connectDB()
    .then(() => {
        const server = app.listen(port, () => {
            console.log(`🚀 Server running on http://localhost:${port}`);
        });

        // Graceful shutdown: Handle process termination
        process.on("SIGINT", async () => {
            console.log("\n🛑 Server shutting down...");
            await mongoose.disconnect();
            server.close(() => {
                console.log("✅ Database disconnected and server closed.");
                process.exit(0);
            });
        });

    }).catch(err => {
        console.error("❌ Failed to connect to database:", err);
        process.exit(1);
    });
