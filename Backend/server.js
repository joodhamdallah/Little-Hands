require("dotenv").config(); // Load environment variables
const express = require("express");
const mongoose = require("mongoose");
const connectDB = require("./database/connection");

const app = express();
const port = process.env.PORT || 3000;

const parentRoutes = require("./routes/parentRoutes");
const caregiverRoutes = require("./routes/caregiverRoutes");
const authRoutes = require("./routes/authRoutes");
const identityRoutes = require("./routes/identityRoutes");
const babysitterRoutes = require('./routes/babysitterRoutes');
const subscriptionRoutes = require('./routes/stripeRoutes');
const stripeWebhookRoute = require('./routes/stripeWebhookRoute');
const workScheduleRoutes = require('./routes/workScheduleRoutes');
const matchRoutes = require('./routes/matchRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const notificationRoutes = require('./routes/notificationRoutes');



app.use('/api/stripe', stripeWebhookRoute);

app.use(express.json({ limit: '30mb' }));
app.use(express.urlencoded({ extended: true, limit: '30mb' }));

// ✅ تفعيل باقي الراوتات
app.use("/api", parentRoutes);
app.use("/api/caregiver", caregiverRoutes);
app.use("/api/auth", authRoutes);
app.use("/api", identityRoutes);
console.log("✅ identityRoutes linked at /api/verify-id");
app.use('/api/babysitter', babysitterRoutes);
app.use('/api', subscriptionRoutes);
app.use('/api/schedule', workScheduleRoutes);
app.use('/api', matchRoutes); 
 app.use('/api', bookingRoutes); 
 app.use('/api', notificationRoutes); 


// ✅ Connect to MongoDB then start the server
connectDB()
    .then(() => {
        const server = app.listen(port, () => {
            console.log(`🚀 Server running on http://localhost:${port}`);
        });

        // ✅ Graceful shutdown
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
