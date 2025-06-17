const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const swaggerOptions = {
    swaggerDefinition: {
        openapi: '3.0.0', // OpenAPI 3.0 specification
        info: {
            title: 'sibayam',
            version: '1.0.0',
            description: 'API documentation for the user authentication and management system.',
        },
        servers: [
            {
                url: 'http://localhost:5000', // Development server URL
                description: 'Production Server'
            },
        ],
        components: {
            securitySchemes: {
                BearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
    },
    apis: ['./routes/*.js'], // Specify the path to your route files
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);

// Swagger setup function
module.exports = (app) => {
    app.use('/api-sibayam/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
};
