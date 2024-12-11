<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1"%> 
<!DOCTYPE html> 
<html>
<head>
    <meta charset="ISO-8859-1">
    <title>Modern Login</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css" rel="stylesheet">
    <style>
        .login-container {
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            min-height: 100vh;
        }
        .form-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 1rem;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }
        .input-field {
            transition: all 0.3s ease;
            border: 2px solid #e5e7eb;
        }
        .input-field:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }
        .login-button {
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            transition: all 0.3s ease;
        }
        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        .register-link {
            color: #6366f1;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        .register-link:hover {
            color: #a855f7;
        }
    </style>
</head>
<body>
    <div class="login-container flex items-center justify-center p-6">
        <div class="form-container w-full max-w-md p-8">
            <div class="text-center mb-8">
                <h1 class="text-3xl font-bold text-gray-800 mb-2">Welcome Back</h1>
                <p class="text-gray-600">Please enter your credentials to login</p>
            </div>
            
            <form action="LoginServlet" method="POST" class="space-y-6">
                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-2">
                        Username
                    </label>
                    <input 
                        type="text" 
                        id="username" 
                        name="username" 
                        required
                        class="input-field w-full px-4 py-3 rounded-lg focus:outline-none"
                        placeholder="Enter your username"
                    >
                </div>

                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                        Password
                    </label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        required
                        class="input-field w-full px-4 py-3 rounded-lg focus:outline-none"
                        placeholder="Enter your password"
                    >
                </div>

                <button 
                    type="submit" 
                    class="login-button w-full text-white font-medium py-3 px-4 rounded-lg hover:opacity-90"
                >
                    Sign In
                </button>
            </form>

            <div class="text-center mt-6">
                <p class="text-sm text-gray-600">
                    Don't have an account? 
                    <a href="register.jsp" class="register-link">Click here to register</a>
                </p>
            </div>
        </div>
    </div>
</body>
</html>
