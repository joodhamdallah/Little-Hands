require("dotenv").config();
const { faker } = require("@faker-js/faker");
const connectDB = require("../connection");
const CareGiver = require("../../models/CareGiver");

const cities = ["طولكرم", "نابلس", "جنين", "رام الله", "الخليل", "غزة", "بيت لحم"];
const genders = ["male", "female"];

async function seedCareGivers() {
  try {
    await connectDB();

    const caregiverCount = await CareGiver.countDocuments();
    if (caregiverCount > 0) {
      console.log("ℹ️ CareGivers already exist in the database. Skipping seeding.");
      process.exit(0);
    }

    const caregivers = [];

    // 🔐 Known CareGiver 1
    caregivers.push(new CareGiver({
      first_name: "Alaa",
      last_name: "Kareem",
      email: "alaa@example.com",
      password: "Alaa123!", // valid password
      phone_number: "0591000000",
      gender: "female",
      date_of_birth: "1993-05-10",
      address: "Al-Quds Street",
      city: "نابلس",
      zip_code: "00972",
      isVerified: true
    }));

    // 🔐 Known CareGiver 2
    caregivers.push(new CareGiver({
      first_name: "Omar",
      last_name: "Zayed",
      email: "omar@example.com",
      password: "Omar123!", // valid password
      phone_number: "0592000000",
      gender: "male",
      date_of_birth: "1988-11-22",
      address: "Freedom Road",
      city: "الخليل",
      zip_code: "00973",
      isVerified: true
    }));

    // 🤖 Generate 10 additional fake caregivers
    for (let i = 0; i < 10; i++) {
      const city = faker.helpers.arrayElement(cities);
      const gender = faker.helpers.arrayElement(genders);
      const first_name = faker.person.firstName(gender);
      const last_name = faker.person.lastName();

      caregivers.push(new CareGiver({
        first_name,
        last_name,
        email: faker.internet.email({ firstName: first_name, lastName: last_name }),
        password: "Password123!", // strong, valid password
        phone_number: faker.phone.number("059########"),
        date_of_birth: faker.date.birthdate({ min: 22, max: 55, mode: "age" }),
        gender,
        address: faker.location.streetAddress(),
        city,
        zip_code: faker.location.zipCode(),
        isVerified: true
      }));
    }

    await CareGiver.insertMany(caregivers);
    console.log("✅ CareGivers seeded successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding caregivers:", error);
    process.exit(1);
  }
}

seedCareGivers();
