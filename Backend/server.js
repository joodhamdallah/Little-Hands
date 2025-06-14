require("dotenv").config(); 
const express = require("express");
const mongoose = require("mongoose");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors"); // ✅ Add this line

const connectDB = require("./database/connection");

const app = express();
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use(cors()); // ✅ Add this line BEFORE any routes

const server = http.createServer(app); // ✅ wrap app with HTTP server
const io = new Server(server, {
  cors: {
    origin: '*', // or specify your frontend domain for security
    methods: ['GET', 'POST']
  },
  transports: ['websocket']

});
app.set('io', io); // ✅ make io accessible inside controllers
// ✅✅✅ ADD THIS LINE BELOW:
global.onlineUsersMap = {}; // 🧠 Initialize the online user map
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
const feedbackRoutes = require('./routes/feedbackRoutes');
const adminRoutes = require('./routes/adminRoutes');
const fallbackRoutes = require('./routes/fallbackRoutes');
const messageRoutes = require('./routes/messageRoutes');
const chatbotRoutes= require ('./routes/chatbotRoutes');
const babysitterRequestRoutes = require('./routes/babysitterRequestRoutes');

const scheduleCompleteBookingsJob = require('./services/cron/completeBookingsJob');


app.use('/api/stripe', stripeWebhookRoute);

app.use(express.json({ limit: '30mb' }));
app.use(express.urlencoded({ extended: true, limit: '30mb' }));

// ✅ تفعيل باقي الراوتات
app.use('/api', notificationRoutes); 
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
app.use("/api", specialNeedsRoutes);
app.use("/api", expertRoutes);
app.use('/api', workPreferenceRoutes);
app.use('/api', specificDateRoutes);
app.use('/api/expert-posts', expertPostRoutes);
app.use('/uploads', express.static('uploads'));
app.use('/api/feedback', feedbackRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api', fallbackRoutes);
app.use('/api/messages', messageRoutes); // ✅ Add message routes
app.use('/api', chatbotRoutes);
app.use('/api/babysitter-requests', babysitterRequestRoutes);




// ✅ Connect to MongoDB then start the server
connectDB()
  .then(() => {    
    
    scheduleCompleteBookingsJob();

    server.listen(port, () => {
      console.log(`🚀 Server + Socket.IO running at http://localhost:${port}`);
    });

    // ✅ Handle Socket.IO connections
 io.on('connection', (socket) => {
  console.log('🧩 Client connected:', socket.id);

  socket.on('join', (userId) => {
    global.onlineUsersMap[userId] = socket.id; // ✅ Store socket ID
    socket.join(userId); // Optional: use room for later if needed
    console.log(`✅ User ${userId} joined. Socket ID: ${socket.id}`);
  });

     socket.on('send_message', (data) => {
    const { senderId, receiverId, content, timestamp } = data;

    // ✅ broadcast to receiver
    io.to(receiverId).emit('receive_message', {
      senderId,
      receiverId,
      content,
      timestamp,
      isRead: false,
    });
  });

  socket.on('disconnect', () => {
    // 🔁 Clean up map
    for (const [uid, sid] of Object.entries(global.onlineUsersMap)) {
      if (sid === socket.id) {
        delete global.onlineUsersMap[uid];
        console.log(`🕳 Removed user ${uid} from online map`);
        break;
      }
    }

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
