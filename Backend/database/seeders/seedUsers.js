require("dotenv").config();
const { faker } = require("@faker-js/faker");
const connectDB = require("../connection");
const User = require("../../models/User");

const cities = ["طولكرم", "نابلس", "جنين", "رام الله", "الخليل", "غزة"];
const roles = ["parent", "expert", "specialist", "sitter"];

async function seedUsers() {
    try {
        await connectDB();

        const userCount = await User.countDocuments();
        if (userCount > 0) {
            console.log("ℹ️ Users already exist in the database. Skipping seeding.");
            process.exit(0);
        }

        const users = [];

        // Admin user
        users.push(new User({
            firstName: "Admin",
            lastName: "User",
            email: "admin@example.com",
            password: "Admin123!", // will be hashed automatically
            phone: "1234567890",
            role: "admin",
            dateOfBirth: "1990-01-01",
            address: "Admin Street",
            city: "رام الله",
            zipCode: "00970"
        }));

        // 10 random users
        for (let i = 0; i < 10; i++) {
            const role = faker.helpers.arrayElement(roles);
            const city = faker.helpers.arrayElement(cities);
            const firstName = faker.person.firstName();
            const lastName = faker.person.lastName();

            users.push(new User({
                firstName,
                lastName,
                email: faker.internet.email({ firstName, lastName }),
                password: "Password123!", // must match validation
                phone: faker.phone.number("059########"),
                role,
                dateOfBirth: faker.date.birthdate({ min: 18, max: 60, mode: "age" }),
                address: faker.location.streetAddress(),
                city,
                zipCode: faker.location.zipCode()
            }));
        }

        await User.insertMany(users);
        console.log("✅ Users seeded successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Error seeding users:", error);
        process.exit(1);
    }
}

seedUsers();
