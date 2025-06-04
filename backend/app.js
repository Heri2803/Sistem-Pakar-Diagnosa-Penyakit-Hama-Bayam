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
const ruleHamaRoutes = require('./routes/ruleHamaRoutes');
const diagnosaRoute = require('./routes/diagnosaRoutes');
const historiRoutes = require('./routes/historiRoutes');
const swaggerDocs = require('./swagger'); 

dotenv.config();

const app = express();




// Middlewares
app.use(express.json());
app.use(cors());

// Serve gambar dari folder image_hama
app.use('/image_hama', express.static(path.join(__dirname, 'image_hama')));
// Serve gambar dari folder image_penyakit
app.use('/image_penyakit', express.static(path.join(__dirname, 'image_penyakit')));

// Routes
app.use("/api/users", userRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/gejala", gejalaRoutes);
app.use("/api/hama", hamaRoutes);
app.use("/api/penyakit", penyakitRoutes);
app.use("/api/rules_penyakit", ruleRoutes);
app.use("/api/rules_hama", ruleHamaRoutes);
app.use("/api/diagnosa", diagnosaRoute);
app.use("/api/histori", historiRoutes);

app.get("/", (req, res) => {
  res.send("Backend API is running 👍");
});


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


// const express = require('express');
// const cors = require('cors');
// const path = require('path');
// const dotenv = require('dotenv');
// const swaggerUi = require('swagger-ui-express');
// const swaggerJsDoc = require('swagger-jsdoc');

// const userRoutes = require('./routes/userRoutes');
// const authRoutes = require('./routes/authRoutes');
// const gejalaRoutes = require('./routes/gejalaRoute');
// const hamaRoutes = require('./routes/hamaRoutes');
// const penyakitRoutes = require('./routes/penyakitRoutes');
// const ruleRoutes = require('./routes/ruleRoutes');
// const ruleHamaRoutes = require('./routes/ruleHamaRoutes');
// const diagnosaRoute = require('./routes/diagnosaRoutes');
// const historiRoutes = require('./routes/historiRoutes');

// dotenv.config();

// const app = express();

// // Swagger config
// const swaggerOptions = {
//   swaggerDefinition: {
//     openapi: '3.0.0',
//     info: {
//       title: 'SIBAYAM API',
//       version: '1.0.0',
//       description: 'API documentation for SIBAYAM',
//     },
//     servers: [
//         {
//       url: 'https://backend-sistem-pakar-diagnosa-penya.vercel.app',
//       description: 'Production Server'
//     },
//     {
//       url: 'http://localhost:5000',
//       description: 'Development Server'
//     }
//     ],
//     components: {
//       securitySchemes: {
//         BearerAuth: {
//           type: 'http',
//           scheme: 'bearer',
//           bearerFormat: 'JWT',
//         },
//       },
//     },
//   },
//   apis: ['./routes/*.js'],
// };

// const swaggerDocs = swaggerJsDoc(swaggerOptions);

// // Middleware
// app.use(cors());
// app.use(express.json());

// // Static image folders
// app.use('/image_hama', express.static(path.join(__dirname, 'image_hama')));
// app.use('/image_penyakit', express.static(path.join(__dirname, 'image_penyakit')));

// // Routes
// app.get('/', (req, res) => {
//   res.send('Backend API is running 👍');
// });

// app.use('/api/users', userRoutes);
// app.use('/api/auth', authRoutes);
// app.use('/api/gejala', gejalaRoutes);
// app.use('/api/hama', hamaRoutes);
// app.use('/api/penyakit', penyakitRoutes);
// app.use('/api/rules_penyakit', ruleRoutes);
// app.use('/api/rules_hama', ruleHamaRoutes);
// app.use('/api/diagnosa', diagnosaRoute);
// app.use('/api/histori', historiRoutes);

// // Swagger UI
// app.use('/api-sibayam', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// // Export for Vercel
// module.exports = app;


