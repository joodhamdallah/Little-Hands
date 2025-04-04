require("dotenv").config();
const bcrypt = require("bcrypt");
const { faker } = require("@faker-js/faker");
const connectDB = require("../connection"); // Import Mongoose connection
const User = require("../../models/User"); // Go up two levels

async function seedUsers() {
    try {
        await connectDB(); // Connect to MongoDB using Mongoose

        // Check if users already exist
        const userCount = await User.countDocuments();
        if (userCount > 0) {
            console.log("ℹ️ Users already exist in the database. Skipping seeding.");
            process.exit(0);
        }

        const users = [];

        // Create an admin user
        users.push(new User({
            firstName: "Admin",
            lastName: "User",
            email: "admin@example.com",
            password: await bcrypt.hash("admin123", 10), // Hashed password
            phone: "1234567890",
            role: "admin",
            dateOfBirth: "1990-01-01",
            address: "Admin Street, City, Country"
        }));

        // Generate 10 fake users
        for (let i = 0; i < 10; i++) {
            users.push(new User({
                firstName: faker.person.firstName(),
                lastName: faker.person.lastName(),
                email: faker.internet.email(),
                password: await bcrypt.hash("password123", 10),
                phone: faker.phone.number(),
                role: faker.helpers.arrayElement(["parent", "expert", "specialist"]),
                dateOfBirth: faker.date.birthdate({ min: 18, max: 60, mode: "age" }).toISOString().split("T")[0],
                address: faker.location.streetAddress()
            }));
        }

        // Insert users into the database
        await User.insertMany(users);
        console.log("✅ Users seeded successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Error seeding users:", error);
        process.exit(1);
    }
}

// Run the script
seedUsers();
