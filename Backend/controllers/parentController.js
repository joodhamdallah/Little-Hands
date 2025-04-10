const ParentServices = require("../services/parentServices");

exports.register = async (req, res, next) => {
    try {
        const {
            firstName, lastName, email, password,
            phone, dateOfBirth, address, city, zipCode
        } = req.body;

        if (!firstName || !lastName || !email || !password || !phone || !dateOfBirth || !address || !city) {
            return res.status(400).json({ status: false, message: "All required fields must be provided!" });
        }

        const response = await ParentServices.registerUser({
            firstName, lastName, email, password,
            phone, dateOfBirth, address, city, zipCode
        });

        res.status(200).json({
            status: true,
            message: response.message,
        });
    }catch (err) {
        console.error("Registration Error:", err);

        // ✅ Specific error message handling
        if (err.message === "User already exists with this email!") {
            return res.status(400).json({
                status: false,
                message: "User already exists with this email!"
            });
        }

        // For other unhandled errors
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

        const user = await ParentServices.checkUser(email);
        if (!user) {
            return res.status(404).json({ status: false, message: "User does not exist!, register now" });
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
        const token = await ParentServices.generateAccessToken(tokenData, "secret", expiresIn);

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
        const { token } = req.query;
        if (!token) return res.status(400).json({ status: false, message: "Verification token is required!" });

        const result = await ParentServices.verifyEmail(token);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Email Verification Error:", err);
        next(err);
    }
};

exports.initiatePasswordReset = async (req, res, next) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ status: false, message: "Email is required!" });

        const result = await ParentServices.initiatePasswordReset(email);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Initiate Password Reset Error:", err);
        next(err);
    }
};

exports.verifyResetToken = async (req, res, next) => {
    try {
        const { token } = req.query;
        if (!token) return res.status(400).json({ status: false, message: "Reset token is required!" });

        const result = await ParentServices.verifyResetToken(token);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Verify Reset Token Error:", err);
        next(err);
    }
};

exports.resetPassword = async (req, res, next) => {
    try {
        const { email, newPassword } = req.body;
        if (!email || !newPassword) {
            return res.status(400).json({ status: false, message: "Email and new password are required!" });
        }

        const result = await ParentServices.resetPassword(email, newPassword);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Password Reset Error:", err);
        return res.status(400).json({
            status: false,
            message: err.message || "Something went wrong"
        });
    }
};
