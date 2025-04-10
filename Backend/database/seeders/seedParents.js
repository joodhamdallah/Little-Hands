require("dotenv").config();
const { faker } = require("@faker-js/faker");
const connectDB = require("../connection");
const Parent = require("../../models/Parent"); // use the updated model

const cities = ["طولكرم", "نابلس", "جنين", "رام الله", "الخليل", "غزة", "بيت لحم"];

async function seedParents() {
    try {
        await connectDB();

        const parentCount = await Parent.countDocuments();
        if (parentCount > 0) {
            console.log("ℹ️ Parents already exist in the database. Skipping seeding.");
            process.exit(0);
        }

        const parents = [];

        // Example parent for login testing
        parents.push(new Parent({
            firstName: "Test",
            lastName: "Parent",
            email: "parent@example.com",
            password: "Parent123!", // must pass regex
            phone: "0590000000",
            dateOfBirth: "1990-01-01",
            address: "Test Street",
            city: "رام الله",
            zipCode: "00970",
            isVerified: true
        }));

        // Generate 10 verified fake parents
        for (let i = 0; i < 10; i++) {
            const city = faker.helpers.arrayElement(cities);
            const firstName = faker.person.firstName();
            const lastName = faker.person.lastName();

            parents.push(new Parent({
                firstName,
                lastName,
                email: faker.internet.email({ firstName, lastName }),
                password: "Password123!", // valid password
                phone: faker.phone.number("059########"),
                dateOfBirth: faker.date.birthdate({ min: 18, max: 60, mode: "age" }),
                address: faker.location.streetAddress(),
                city,
                zipCode: faker.location.zipCode(),
                isVerified: true
            }));
        }

        await Parent.insertMany(parents);
        console.log("✅ Parents seeded successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Error seeding parents:", error);
        process.exit(1);
    }
}

seedParents();
