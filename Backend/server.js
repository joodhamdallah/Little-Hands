require("dotenv").config(); // Load environment variables
const express = require("express");
const mongoose = require("mongoose");
const http = require("http"); // ✅ for wrapping express
const { Server } = require("socket.io"); // ✅ import Socket.IO
const connectDB = require("./database/connection");

const app = express();
const server = http.createServer(app); // ✅ wrap app with HTTP server
const io = new Server(server, {
  cors: {
    origin: '*', // or specify your frontend domain for security
    methods: ['GET', 'POST']
  }
});
app.set('io', io); // ✅ make io accessible inside controllers

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
const specialNeedsRoutes = require('./routes/specialNeedsRoutes');
const expertRoutes = require("./routes/expertRoutes");
const workPreferenceRoutes = require('./routes/weeklyPreferenceRoutes');
const specificDateRoutes = require('./routes/specificDateRoutes');
const expertPostRoutes = require('./routes/expertPostRoutes');



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
app.use("/api", specialNeedsRoutes);
app.use("/api", expertRoutes);
app.use('/api', workPreferenceRoutes);
app.use('/api', specificDateRoutes);
app.use('/api/expert-posts', expertPostRoutes);
app.use('/uploads', express.static('uploads'));



// ✅ Connect to MongoDB then start the server
connectDB()
  .then(() => {
    server.listen(port, () => {
      console.log(`🚀 Server + Socket.IO running at http://localhost:${port}`);
    });

    // ✅ Handle Socket.IO connections
    io.on('connection', (socket) => {
      console.log('🧩 Client connected:', socket.id);

      socket.on('join', (userId) => {
        socket.join(userId);
        console.log(`✅ User ${userId} joined their room`);
      });

      socket.on('disconnect', () => {
        console.log('🚪 Client disconnected:', socket.id);
      });
    });

    process.on("SIGINT", async () => {
  console.log("\n🛑 Server shutting down...");

  // ✅ Gracefully disconnect all active Socket.IO clients
  io.sockets.sockets.forEach((socket) => {
    socket.disconnect(true);
  });

  // ✅ Close MongoDB connection
  await mongoose.disconnect();

  // ✅ Stop accepting new connections and close the server
  server.close(() => {
    console.log("✅ Database disconnected and server closed.");
    process.exit(0);
  });

  // 🕐 Optional failsafe: force exit after 5 seconds if stuck
  setTimeout(() => {
    console.warn("⚠️ Force shutdown due to timeout");
    process.exit(1);
  }, 5000);
});


  })
  .catch(err => {
    console.error("❌ Failed to connect to database:", err);
    process.exit(1);
  });
