const mongoose = require('mongoose');
require('dotenv').config();

const Book = require('./models/Book');
const PPT = require('./models/PPT');
const Project = require('./models/Project');
const Assignment = require('./models/Assignment');
const Note = require('./models/Note');
const Test = require('./models/Test');

async function clearDatabase() {
    try {
        const mongoUri = process.env.MONGODB_URI || process.env.DATABASE_URL || process.env.MONGO_URL;
        await mongoose.connect(mongoUri);
        console.log('Connected to MongoDB');

        // Delete all collections
        await Book.deleteMany({});
        console.log('✓ Deleted all books');

        await PPT.deleteMany({});
        console.log('✓ Deleted all PPTs');

        await Project.deleteMany({});
        console.log('✓ Deleted all projects');

        await Assignment.deleteMany({});
        console.log('✓ Deleted all assignments');

        await Note.deleteMany({});
        console.log('✓ Deleted all notes');

        await Test.deleteMany({});
        console.log('✓ Deleted all tests');

        console.log('\n🎉 Database cleared successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error clearing database:', error);
        process.exit(1);
    }
}

clearDatabase();