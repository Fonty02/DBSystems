<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="ISO-8859-1">
    <title>Login Error</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css" rel="stylesheet">
    <style>
        .login-container {
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            min-height: 100vh;
        }
        .error-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 1rem;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
        }
        .input-field {
            transition: all 0.3s ease;
            border: 2px solid #fee2e2;
        }
        .input-field:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
        }
        .retry-button {
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            transition: all 0.3s ease;
        }
        .retry-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }
        .error-icon {
            animation: shake 0.8s cubic-bezier(.36,.07,.19,.97) both;
        }
    </style>
</head>
<body>
    <div class="login-container flex items-center justify-center p-6">
        <div class="error-container w-full max-w-md p-8">
            <div class="text-center mb-8">
                <div class="flex justify-center mb-4">
                    <div class="error-icon bg-red-100 rounded-full p-4">
                        <svg class="w-12 h-12 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                        </svg>
                    </div>
                </div>
                <h1 class="text-3xl font-bold text-gray-800 mb-2">Accesso Negato</h1>
                <p class="text-red-600 font-medium mb-2">Credenziali non valide</p>
                <p class="text-gray-600">Le credenziali inserite non sono corrette. Per favore riprova.</p>
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
                        placeholder="Inserisci il tuo username"
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
                        placeholder="Inserisci la tua password"
                    >
                </div>

                <button 
                    type="submit" 
                    class="retry-button w-full text-white font-medium py-3 px-4 rounded-lg hover:opacity-90"
                >
                    Riprova
                </button>

                <div class="text-center">
                    <a href="#" class="text-sm text-indigo-600 hover:text-indigo-800">
                        Hai dimenticato la password?
                    </a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>