const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const sequelize = require('./config/database');
const path = require('path');
const userRoutes = require('./routes/userRoutes');
const authRoutes = require('./routes/authRoutes');
const gejalaRoutes = require('./routes/gejalaRoute');
const hamaRoutes = require('./routes/hamaRoutes');
const penyakitRoutes = require('./routes/penyakitRoutes');
const ruleRoutes = require('./routes/ruleRoutes');
const swaggerDocs = require('./swagger'); 

dotenv.config();

const app = express();

// Middlewares
app.use(express.json());
app.use(cors());

// Routes
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/gejala", gejalaRoutes);
app.use("/api/hama", hamaRoutes);
app.use("/api/penyakit", penyakitRoutes);
app.use("/api/rules", ruleRoutes);


// Swagger Documentation
swaggerDocs(app); // Setup Swagger UI documentation

const PORT = process.env.PORT || 5000;

// Database Initialization
const initializeDatabase = async () => {
    try {
        await sequelize.sync({ force: false });
        console.log('Database synced');
    } catch (error) {
        console.error('Error syncing database:', error);
        throw error;
    }
};

// Start Server
initializeDatabase()
    .then(() => {
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
            console.log(`Swagger UI available at http://localhost:${PORT}/api-sibayam`);
        });
    })
    .catch((error) => {
        console.error('Error starting the server:', error);
        process.exit(1);
    });
