const UserServices = require("../services/userServices");

exports.register = async (req, res, next) => {
    try {
        console.log("--- User Registration Request ---", req.body);

        const {
            firstName,
            lastName,
            email,
            password,
            phone,
            role,
            dateOfBirth,
            address,
            city,
            zipCode // optional
        } = req.body;

        if (!firstName || !lastName || !email || !password || !phone || !role || !dateOfBirth || !address || !city) {
            throw new Error("All required fields must be provided!");
        }

        // Check if the user already exists
        const existingUser = await UserServices.getUserByEmail(email);
        if (existingUser) {
            return res.status(400).json({ status: false, message: `User with email ${email} already registered!` });
        }

        // Register the user
        const response = await UserServices.registerUser(
            firstName,
            lastName,
            email,
            password,
            phone,
            role,
            dateOfBirth,
            address,
            city,
            zipCode
        );

        res.status(201).json({
            status: true,
            message: "User registered successfully! Please verify your email.",
            emailToken: response.emailToken,
            user: response.user
        });

    } catch (err) {
        console.error("Registration Error --->", err);
        next(err);
    }
};

exports.login = async (req, res, next) => {
    try {
        console.log("--- User Login Request ---", req.body);
        const { email, password, rememberMe } = req.body;

        if (!email || !password) {
            return res.status(400).json({ status: false, message: "Email and password are required!" });
        }

        const user = await UserServices.checkUser(email);
        if (!user) {
            return res.status(404).json({ status: false, message: "User does not exist!" });
        }

        const isPasswordCorrect = await user.comparePassword(password);
        if (!isPasswordCorrect) {
            return res.status(401).json({ status: false, message: "Incorrect email or password!" });
        }

        if (!user.isVerified) {
            return res.status(403).json({ status: false, message: "Email not verified. Please check your inbox." });
        }

        const expiresIn = rememberMe ? "7d" : "1h";
        const tokenData = { _id: user._id, email: user.email, role: user.role };
        const token = await UserServices.generateAccessToken(tokenData, "secret", expiresIn);

        res.status(200).json({ 
            status: true, 
            message: "Login successful!", 
            token: token,
            expiresIn: expiresIn,
            user: {
                id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                role: user.role
            }
        });

    } catch (error) {
        console.error("Login Error --->", error);
        next(error);
    }
};

exports.verifyEmail = async (req, res, next) => {
    try {
        const token = req.query.token || req.body.token;
        if (!token) {
            return res.status(400).json({ status: false, message: "Verification token is required!" });
        }

        const response = await UserServices.verifyEmail(token);
        res.status(200).json({ status: true, message: response.message });

    } catch (error) {
        console.error("Email Verification Error --->", error);
        next(error);
    }
};

exports.initiatePasswordReset = async (req, res, next) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ status: false, message: "Email is required!" });
        }

        const response = await UserServices.initiatePasswordReset(email);
        res.status(200).json({ status: true, message: response.message, resetToken: response.resetToken });

    } catch (error) {
        console.error("Password Reset Request Error --->", error);
        next(error);
    }
};

exports.resetPassword = async (req, res, next) => {
    try {
        const { token, newPassword } = req.body;
        if (!token || !newPassword) {
            return res.status(400).json({ status: false, message: "Token and new password are required!" });
        }

        const response = await UserServices.resetPassword(token, newPassword);
        res.status(200).json({ status: true, message: response.message });

    } catch (error) {
        console.error("Password Reset Error --->", error);
        next(error);
    }
};
