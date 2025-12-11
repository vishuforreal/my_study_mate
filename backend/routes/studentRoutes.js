const express = require('express');
const router = express.Router();
const { protect, checkPermission } = require('../middleware/authMiddleware');
const Note = require('../models/Note');
const Book = require('../models/Book');
const Test = require('../models/Test');
const PPT = require('../models/PPT');
const Project = require('../models/Project');
const Assignment = require('../models/Assignment');

// @route   GET /api/student/notes
// @desc    Get all notes for student
// @access  Private (Student)
router.get('/notes', protect, checkPermission('notes'), async (req, res) => {
    try {
        const { subject, search } = req.query;
        
        let query = {};
        
        // Only filter by category for students
        if (req.user.role === 'student' && req.user.category) {
            query.category = req.user.category;
            
            if (req.user.subcategory) {
                query.subcategory = req.user.subcategory;
            }
        }
        
        if (subject) query.subject = subject;
        
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } },
                { subject: { $regex: search, $options: 'i' } }
            ];
        }

        const notes = await Note.find(query).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: notes.length,
            notes
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching notes',
            error: error.message
        });
    }
});

// @route   GET /api/student/books
// @desc    Get all books for student
// @access  Private (Student)
router.get('/books', protect, checkPermission('books'), async (req, res) => {
    try {
        const { subject, search } = req.query;
        
        let query = {};
        
        // Only filter by category for students
        if (req.user.role === 'student' && req.user.category) {
            query.category = req.user.category;
            
            if (req.user.subcategory) {
                query.subcategory = req.user.subcategory;
            }
        }
        
        if (subject) query.subject = subject;
        
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { author: { $regex: search, $options: 'i' } },
                { subject: { $regex: search, $options: 'i' } }
            ];
        }

        const books = await Book.find(query).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: books.length,
            books
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching books',
            error: error.message
        });
    }
});

// @route   GET /api/student/tests
// @desc    Get all tests for student
// @access  Private (Student)
router.get('/tests', protect, checkPermission('tests'), async (req, res) => {
    try {
        const { subject, difficulty, search } = req.query;
        
        let query = {};
        
        // Only filter by category for students
        if (req.user.role === 'student' && req.user.category) {
            query.category = req.user.category;
            
            if (req.user.subcategory) {
                query.subcategory = req.user.subcategory;
            }
        }
        
        if (subject) query.subject = subject;
        if (difficulty) query.difficulty = difficulty;
        
        if (search) {
            query.$or = [
                { title: { $regex: search, $options: 'i' } },
                { description: { $regex: search, $options: 'i' } },
                { subject: { $regex: search, $options: 'i' } }
            ];
        }

        const tests = await Test.find(query).select('-questions.correctAnswer -questions.explanation').sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: tests.length,
            tests
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching tests',
            error: error.message
        });
    }
});

// @route   GET /api/student/tests/:id
// @desc    Get single test with questions
// @access  Private (Student)
router.get('/tests/:id', protect, checkPermission('tests'), async (req, res) => {
    try {
        const test = await Test.findById(req.params.id);

        if (!test) {
            return res.status(404).json({
                success: false,
                message: 'Test not found'
            });
        }

        // Send questions without correct answers
        const testData = {
            ...test.toObject(),
            questions: test.questions.map(q => ({
                question: q.question,
                options: q.options,
                _id: q._id
            }))
        };

        res.status(200).json({
            success: true,
            test: testData
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching test',
            error: error.message
        });
    }
});

// @route   POST /api/student/tests/:id/submit
// @desc    Submit test and get results
// @access  Private (Student)
router.post('/tests/:id/submit', protect, checkPermission('tests'), async (req, res) => {
    try {
        const { answers } = req.body; // Array of {questionId, selectedAnswer}

        const test = await Test.findById(req.params.id);

        if (!test) {
            return res.status(404).json({
                success: false,
                message: 'Test not found'
            });
        }

        // Calculate score
        let correctAnswers = 0;
        const results = test.questions.map((question, index) => {
            const userAnswer = answers.find(a => a.questionId === question._id.toString());
            const isCorrect = userAnswer && userAnswer.selectedAnswer === question.correctAnswer;

            if (isCorrect) correctAnswers++;

            return {
                questionId: question._id,
                question: question.question,
                userAnswer: userAnswer ? userAnswer.selectedAnswer : null,
                correctAnswer: question.correctAnswer,
                isCorrect,
                explanation: question.explanation
            };
        });

        const score = (correctAnswers / test.questions.length) * test.totalMarks;
        const passed = score >= test.passingMarks;

        // Increment attempts
        test.attempts += 1;
        await test.save();

        res.status(200).json({
            success: true,
            results: {
                totalQuestions: test.questions.length,
                correctAnswers,
                score,
                totalMarks: test.totalMarks,
                passingMarks: test.passingMarks,
                passed,
                details: results
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error submitting test',
            error: error.message
        });
    }
});

// @route   GET /api/student/ppts
// @desc    Get all PPTs for student
// @access  Private (Student)
router.get('/ppts', protect, checkPermission('ppts'), async (req, res) => {
    try {
        const { category, course, subject } = req.query;

        let query = {};
        if (category) query.category = category;
        if (course) query.course = course;
        if (subject) query.subject = subject;

        const ppts = await PPT.find(query).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: ppts.length,
            ppts
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching PPTs',
            error: error.message
        });
    }
});

// @route   GET /api/student/projects
// @desc    Get all projects for student
// @access  Private (Student)
router.get('/projects', protect, checkPermission('projects'), async (req, res) => {
    try {
        const { category, technology, difficulty } = req.query;

        let query = {};
        if (category) query.category = category;
        if (technology) query.technology = new RegExp(technology, 'i');
        if (difficulty) query.difficulty = difficulty;

        const projects = await Project.find(query).sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: projects.length,
            projects
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching projects',
            error: error.message
        });
    }
});

// @route   GET /api/student/assignments
// @desc    Get all assignments for student
// @access  Private (Student)
router.get('/assignments', protect, checkPermission('assignments'), async (req, res) => {
    try {
        const { category, course, subject } = req.query;

        let query = {};
        if (category) query.category = category;
        if (course) query.course = course;
        if (subject) query.subject = subject;

        const assignments = await Assignment.find(query).sort({ deadline: 1 });

        res.status(200).json({
            success: true,
            count: assignments.length,
            assignments
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching assignments',
            error: error.message
        });
    }
});

// @route   PUT /api/student/download/:type/:id
// @desc    Increment download count
// @access  Private (Student)
router.put('/download/:type/:id', protect, async (req, res) => {
    try {
        const { type, id } = req.params;

        let Model;
        switch (type) {
            case 'note':
                Model = Note;
                break;
            case 'book':
                Model = Book;
                break;
            case 'ppt':
                Model = PPT;
                break;
            case 'project':
                Model = Project;
                break;
            case 'assignment':
                Model = Assignment;
                break;
            default:
                return res.status(400).json({
                    success: false,
                    message: 'Invalid content type'
                });
        }

        const item = await Model.findByIdAndUpdate(
            id,
            { $inc: { downloads: 1 } },
            { new: true }
        );

        if (!item) {
            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Download count updated'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating download count',
            error: error.message
        });
    }
});

module.exports = router;
