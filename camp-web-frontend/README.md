# CAMP Web Frontend

A modern, responsive web frontend for the Cloud Asset Management Platform with dark theme, drag-and-drop file upload, and real-time asset management capabilities.

## 🏗️ Frontend Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            CAMP Web Frontend                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐              │
│  │   UI Layer      │    │  Logic Layer    │    │  API Layer      │              │
│  │                 │    │                 │    │                 │              │
│  │ • HTML/CSS      │◄──►│ • JavaScript    │◄──►│ • Fetch API     │              │
│  │ • Dark Theme    │    │ • State Mgmt    │    │ • HTTP Client    │              │
│  │ • Responsive    │    │ • File Handling │    │ • Error Handling │              │
│  │ • Accessibility │    │ • Notifications │    │ • Configuration │              │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘              │
│           │                       │                       │                      │
│           └───────────────────────┼───────────────────────┘                      │
│                                   │                                              │
│                          ┌─────────────────┐                                      │
│                          │   Backend API   │                                      │
│                          │   (Port 8000)   │                                      │
│                          │                 │                                      │
│                          │ • FastAPI       │                                      │
│                          │ • File Upload   │                                      │
│                          │ • Asset Mgmt    │                                      │
│                          └─────────────────┘                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 📁 File Structure

```
camp-web-frontend/
├── README.md                    # This documentation
├── serve.py                     # Development server
├── package.json                 # Node.js dependencies
├── start.bat                    # Windows startup script
├── index.html                   # Main application page
├── styles.css                   # Custom CSS (dark theme)
├── config.js                    # API configuration
├── app.js                       # Main application logic
├── api-client.js                # API communication layer
├── api-tester.js                # API testing interface
├── debug.html                   # Debug and testing page
├── test-image.html              # Image upload testing
└── API_DOCUMENTATION.md         # API usage guide
```

## 🚀 Quick Start

### Prerequisites
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- Python 3.8+ (for development server)
- Optional: Node.js (for package management)

### Running the Application

#### Method 1: Python Server (Recommended)
```bash
cd camp-web-frontend
python serve.py
```
Access at: `http://localhost:3004`

#### Method 2: Direct File Opening
```bash
# Simply open index.html in your browser
open index.html  # macOS
start index.html  # Windows
xdg-open index.html  # Linux
```

#### Method 3: Node.js Server
```bash
cd camp-web-frontend
npm install
npm start
```

### Development Features
- **Live Reload**: Automatic page refresh on changes
- **CORS Enabled**: Cross-origin API requests
- **Error Handling**: Comprehensive error display
- **Debug Mode**: Built-in API testing tools

## ✨ Features

### 🎨 User Interface
- **Dark Theme**: Modern dark color scheme matching CAMP design
- **Responsive Design**: Mobile-friendly layout
- **Accessibility**: WCAG compliant with ARIA labels
- **Smooth Animations**: CSS transitions and micro-interactions
- **Font Awesome Icons**: Professional iconography

### 📁 File Management
- **Drag & Drop Upload**: Intuitive file upload interface
- **File Grid Display**: Visual asset organization
- **Real-time Updates**: Live file list updates
- **File Operations**: Rename and delete capabilities
- **Progress Tracking**: Upload progress indicators
- **File Type Detection**: Visual icons for different file types

### 🔔 User Experience
- **Toast Notifications**: Success/error feedback
- **Loading States**: Visual loading indicators
- **Error Recovery**: Graceful error handling
- **Keyboard Navigation**: Full keyboard accessibility
- **Mobile Gestures**: Touch-friendly interactions

### 🛠️ Development Tools
- **API Tester**: Built-in API testing interface
- **Debug Console**: Enhanced debugging information
- **Health Monitoring**: Backend connectivity checks
- **Configuration Management**: Easy API endpoint configuration

## 🎨 Design System

### Color Palette (Dark Theme)
```css
/* Primary Colors */
--bg-primary: #1a1a2e;        /* Main background */
--bg-secondary: #16213e;      /* Card backgrounds */
--bg-tertiary: #0f3460;       /* Borders and accents */
--accent-primary: #f39c12;    /* Primary accent (orange) */
--accent-secondary: #e67e22;  /* Hover states */

/* Text Colors */
--text-primary: #eee;         /* Main text */
--text-secondary: #a8a8a8;    /* Secondary text */
--text-muted: #666;          /* Muted text */

/* Status Colors */
--success: #27ae60;           /* Success states */
--error: #e74c3c;             /* Error states */
--warning: #f39c12;           /* Warning states */
--info: #17a2b8;              /* Info states */
```

### Typography
- **Font Family**: System fonts (-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto)
- **Font Sizes**: Responsive scaling from 0.8rem to 2rem
- **Font Weights**: 400 (normal), 500 (medium), 600 (semibold)
- **Line Height**: 1.6 for readability

### Component Styles
- **Cards**: Rounded corners (8px), subtle shadows, border accents
- **Buttons**: Consistent padding, hover effects, disabled states
- **Forms**: Dark input fields, focus states, validation styling
- **Notifications**: Slide-in animations, auto-dismiss, color-coded

## 🔧 Configuration

### API Configuration (config.js)
```javascript
const API_CONFIG = {
    BASE_URL: 'http://localhost:8000',
    VERSION: 'v1',
    ENDPOINTS: {
        HEALTH: '/',
        UPLOAD: '/api/v1/upload',
        FILES: '/api/v1/files',
        DELETE: '/api/v1/files/{id}'
    },
    TIMEOUT: 30000,  // 30 seconds
    RETRY_ATTEMPTS: 3,
    CHUNK_SIZE: 8192  // For file uploads
};
```

### Application Settings
```javascript
const APP_CONFIG = {
    NAME: 'Cloud Asset Management Platform',
    VERSION: '1.0.0',
    MAX_FILE_SIZE: 50 * 1024 * 1024,  // 50MB
    SUPPORTED_FORMATS: [
        'image/jpeg', 'image/png', 'image/gif',
        'application/pdf', 'text/plain',
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ],
    PAGINATION: {
        DEFAULT_LIMIT: 20,
        MAX_LIMIT: 100
    }
};
```

## 📡 API Integration

### HTTP Client Features
- **Request Interceptors**: Automatic authentication headers
- **Response Interceptors**: Error handling and logging
- **Retry Logic**: Automatic retry for failed requests
- **Timeout Management**: Configurable request timeouts
- **Progress Tracking**: Upload/download progress

### API Endpoints Used
```javascript
// Health Check
GET http://localhost:8000/

// File Upload
POST http://localhost:8000/api/v1/upload
Content-Type: multipart/form-data

// List Files
GET http://localhost:8000/api/v1/files

// Delete File
DELETE http://localhost:8000/api/v1/files/{id}

// Update File Metadata
PUT http://localhost:8000/api/v1/files/{id}
```

### Error Handling
```javascript
// HTTP Status Code Handling
200: Success response
201: Resource created
400: Bad request
404: Resource not found
413: File too large
422: Validation error
500: Server error

// Client-side Error Categories
NetworkError: Connection issues
ValidationError: Invalid input
AuthenticationError: Auth required
FileSystemError: Browser limitations
```

## 🎯 Core Components

### File Upload Component
```javascript
class FileUploader {
    constructor(options = {}) {
        this.maxFileSize = options.maxFileSize || 50 * 1024 * 1024;
        this.acceptedTypes = options.acceptedTypes || [];
        this.onProgress = options.onProgress || (() => {});
        this.onSuccess = options.onSuccess || (() => {});
        this.onError = options.onError || (() => {});
    }
    
    async upload(file) {
        // Validation
        this.validateFile(file);
        
        // Upload with progress tracking
        return this.uploadWithProgress(file);
    }
}
```

### Asset Grid Component
```javascript
class AssetGrid {
    constructor(container) {
        this.container = container;
        this.assets = [];
        this.selectedAssets = new Set();
    }
    
    render(assets) {
        // Render file grid with cards
        this.createAssetCards(assets);
    }
    
    handleAssetAction(action, assetId) {
        // Handle rename, delete, download actions
    }
}
```

### Notification System
```javascript
class NotificationManager {
    show(message, type = 'info', duration = 5000) {
        const notification = this.createNotification(message, type);
        this.container.appendChild(notification);
        
        // Auto-dismiss
        setTimeout(() => {
            this.dismiss(notification);
        }, duration);
    }
}
```

## 📱 Responsive Design

### Breakpoints
```css
/* Mobile */
@media (max-width: 480px) {
    .container { padding: 10px; }
    .file-grid { grid-template-columns: 1fr; }
}

/* Tablet */
@media (max-width: 768px) {
    .header-content { flex-direction: column; }
    .file-grid { grid-template-columns: repeat(2, 1fr); }
}

/* Desktop */
@media (min-width: 1200px) {
    .container { max-width: 1200px; }
    .file-grid { grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
}
```

### Mobile Optimizations
- **Touch Targets**: Minimum 44px tap targets
- **Swipe Gestures**: Touch-friendly interactions
- **Virtual Keyboard**: Proper viewport handling
- **Performance**: Optimized for mobile processors

## 🔍 Development Tools

### API Tester (api-tester.js)
- **Interactive Testing**: Test all API endpoints
- **Request Builder**: Build custom requests
- **Response Viewer**: Formatted JSON responses
- **History Tracking**: Request/response history

### Debug Page (debug.html)
- **System Information**: Browser and environment details
- **API Connectivity**: Backend health checks
- **File Upload Testing**: Test various file types
- **Performance Metrics**: Load times and sizes

### Console Logging
```javascript
// Development logging
console.log('CAMP Frontend:', message);
console.debug('Debug info:', data);
console.warn('Warning:', issue);
console.error('Error:', error);

// Production logging (filtered)
if (window.APP_CONFIG.DEBUG) {
    console.log('Debug mode enabled');
}
```

## 🧪 Testing

### Manual Testing Checklist
- [ ] File upload with various formats
- [ ] Drag and drop functionality
- [ ] File deletion and renaming
- [ ] Responsive design on mobile
- [ ] Keyboard navigation
- [ ] Screen reader compatibility
- [ ] Error handling scenarios
- [ ] Network connectivity issues

### Automated Testing (Future)
```javascript
// Example test structure
describe('File Upload', () => {
    it('should upload valid file', async () => {
        const file = new File(['content'], 'test.txt', { type: 'text/plain' });
        const result = await fileUploader.upload(file);
        expect(result.success).toBe(true);
    });
    
    it('should reject oversized file', async () => {
        const largeFile = new File(['x'.repeat(100 * 1024 * 1024)], 'large.txt');
        await expect(fileUploader.upload(largeFile)).rejects.toThrow('File too large');
    });
});
```

### Cross-Browser Testing
- **Chrome**: Full feature support
- **Firefox**: Full feature support
- **Safari**: Full feature support
- **Edge**: Full feature support
- **Mobile Safari**: iOS optimization
- **Chrome Mobile**: Android optimization

## 🚀 Performance Optimization

### Loading Performance
- **Lazy Loading**: Load files on demand
- **Image Optimization**: Proper image sizing
- **Code Splitting**: Separate vendor bundles
- **Caching**: Browser cache optimization

### Runtime Performance
- **Debouncing**: Efficient event handling
- **Throttling**: Rate-limit API calls
- **Memory Management**: Proper cleanup
- **Animation Optimization**: CSS transforms over JavaScript

### Network Optimization
- **Request Batching**: Group API calls
- **Compression**: Gzip response compression
- **CDN Ready**: Static asset optimization
- **Offline Support**: Service worker (future)

## 🔒 Security Considerations

### Client-Side Security
- **Input Validation**: File type and size validation
- **XSS Prevention**: Proper output encoding
- **CSRF Protection**: Token-based requests
- **Content Security Policy**: Secure resource loading

### Data Protection
- **Sensitive Data**: No sensitive data in localStorage
- **Session Management**: Proper cleanup on logout
- **API Keys**: Environment-based configuration
- **Error Messages**: Sanitized error display

### File Security
```javascript
// File validation example
function validateFile(file) {
    const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    const maxSize = 50 * 1024 * 1024; // 50MB
    
    if (!allowedTypes.includes(file.type)) {
        throw new Error('File type not allowed');
    }
    
    if (file.size > maxSize) {
        throw new Error('File too large');
    }
    
    return true;
}
```

## 🌐 Browser Compatibility

### Supported Browsers
- **Chrome** 90+ (recommended)
- **Firefox** 88+
- **Safari** 14+
- **Edge** 90+

### Modern Features Used
- **ES6+ JavaScript**: Arrow functions, async/await, classes
- **CSS Grid**: Layout system
- **CSS Custom Properties**: Theme variables
- **Fetch API**: HTTP requests
- **File API**: File handling
- **Drag & Drop API**: File upload
- **Intersection Observer**: Lazy loading (future)

### Polyfills (if needed)
```html
<!-- For older browsers -->
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6,fetch"></script>
```

## 📚 Documentation

### API Documentation
- **Internal**: `API_DOCUMENTATION.md`
- **External**: `http://localhost:8000/docs` (when backend is running)
- **Interactive**: Built-in API tester

### Code Documentation
```javascript
/**
 * Uploads a file to the server
 * @param {File} file - The file to upload
 * @param {Function} onProgress - Progress callback
 * @returns {Promise<Object>} Upload result
 * @throws {Error} When file validation fails
 */
async function uploadFile(file, onProgress) {
    // Implementation
}
```

## 🔄 Integration Flow

### Authentication Integration
```
1. User visits auth frontend (8081)
2. Successful login redirects to main app (3004)
3. Session token stored in localStorage
4. API calls include authentication headers
5. Session timeout handling
```

### File Management Flow
```
1. User selects/drops files
2. Client-side validation
3. Upload progress tracking
4. Backend processing
5. Database storage
6. UI updates with new file
7. Error handling if needed
```

## 🚀 Deployment

### Static Hosting
```bash
# Build for production
npm run build  # If using build tools

# Deploy to static hosting
rsync -av dist/ user@server:/var/www/camp/
```

### CDN Configuration
```javascript
// CDN asset loading
const CDN_BASE = 'https://cdn.example.com/camp';
const API_BASE = 'https://api.example.com';
```

### Environment Variables
```javascript
// Production configuration
const PROD_CONFIG = {
    API_BASE_URL: 'https://api.camp.com',
    CDN_BASE_URL: 'https://cdn.camp.com',
    DEBUG: false,
    LOG_LEVEL: 'error'
};
```

## 🤝 Contributing

### Development Setup
```bash
# Clone repository
git clone <repository-url>
cd camp-web-frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

### Code Style
- **JavaScript**: ES6+ standards
- **CSS**: BEM methodology
- **HTML**: Semantic markup
- **Accessibility**: WCAG 2.1 AA compliance

### Pull Request Process
1. Create feature branch
2. Implement changes with tests
3. Ensure accessibility compliance
4. Update documentation
5. Submit pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

### Troubleshooting
```bash
# Check browser console for errors
# Verify backend connectivity
# Test API endpoints directly
# Check CORS configuration
```

### Common Issues
- **CORS Errors**: Backend not configured for frontend origin
- **Upload Failures**: File size limits or network issues
- **Display Issues**: Clear browser cache and reload
- **Performance**: Disable browser extensions for testing

### Getting Help
1. Check browser developer console
2. Review API documentation
3. Test with different file types
4. Verify network connectivity
5. Open GitHub issue with details

---

**Built with ❤️ using HTML5, CSS3, JavaScript ES6+, and modern web standards**

**Version**: 1.0.0  
**Last Updated**: 2026-04-03  
**Status**: Production Ready
