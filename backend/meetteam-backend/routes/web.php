<?php


use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Mail;
use Illuminate\Http\Request;

// Route pour afficher le formulaire de réinitialisation
Route::get('/reset-password/{token}', function (Request $request, $token) {
    return view('auth.reset-password', [
        'token' => $token,
        'email' => $request->email
    ]);
})->middleware('guest')->name('password.reset');

// Route pour traiter la réinitialisation
Route::post('/reset-password', [AuthController::class, 'resetPasswordWeb'])
    ->middleware('guest')
    ->name('password.update');

// Route pour les tests
Route::get('/test-email', function () {
    return view('auth.reset-password', [
        'token' => 'test-token-123',
        'email' => 'test@example.com'
    ]);
});

Route::get('/', function () {
    return view('welcome');
});

Route::get('/test-email', function () {
    try {
        \Mail::raw('Test email from Meetteam', function ($message) {
            $message->to('meetteam71@gmail.com')
                    ->subject('Test Email');
        });
        
        return 'Email sent successfully!';
    } catch (\Exception $e) {
        return 'Error: ' . $e->getMessage();
    }
});

// Routes de réinitialisation de mot de passe (nécessaires pour les emails)
Route::get('/reset-password/{token}', function ($token) {
    return view('auth.reset-password', ['token' => $token]);
})->middleware('guest')->name('password.reset');

Route::post('/reset-password', [AuthController::class, 'resetPasswordWeb'])
    ->middleware('guest')
    ->name('password.update');

// Route pour afficher le formulaire de demande de réinitialisation
Route::get('/forgot-password', function () {
    return view('auth.forgot-password');
})->middleware('guest')->name('password.request');