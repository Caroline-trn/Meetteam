<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Hash;
use App\Notifications\PasswordResetCode;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Support\Facades\Validator;


class AuthController extends Controller
{

    



public function sendResetCode(Request $request)
{
    $request->validate(['email' => 'required|email']);
     Log::info('Request email: ' . $request->email);
    $user = User::where('email', $request->email)->first();

    if (!$user) {
        return response()->json([
            'message' => 'Si cet email existe, un code de réinitialisation a été envoyé.'
        ], 200);
    }

    // Générer un code de 6 chiffres
    $code = rand(100000, 999999);
    
    // Sauvegarder le code et sa date d'expiration
    $user->update([
        'reset_code' => $code,
        'reset_code_expires_at' => Carbon::now()->addMinutes(15)
    ]);

    // Envoyer le code par email
    $user->notify(new PasswordResetCode($code));

    return response()->json([
        'message' => 'Un code de réinitialisation a été envoyé à votre email.'
    ], 200);
}

public function verifyResetCode(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'code' => 'required|numeric|digits:6'
    ]);

    $user = User::where('email', $request->email)
                ->where('reset_code', $request->code)
                ->where('reset_code_expires_at', '>', Carbon::now())
                ->first();

    if (!$user) {
        return response()->json([
            'message' => 'Code invalide ou expiré.'
        ], 422);
    }

    return response()->json([
        'message' => 'Code validé avec succès.',
        'verified' => true
    ], 200);
}

public function resetPasswordWithCode(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'code' => 'required|numeric|digits:6',
        'password' => 'required|min:6|confirmed',
    ]);

    $user = User::where('email', $request->email)
                ->where('reset_code', $request->code)
                ->where('reset_code_expires_at', '>', Carbon::now())
                ->first();

    if (!$user) {
        return response()->json([
            'message' => 'Code invalide ou expiré.'
        ], 422);
    }

    // Mettre à jour le mot de passe
    $user->update([
        'password' => Hash::make($request->password),
        'reset_code' => null,
        'reset_code_expires_at' => null
    ]);

    return response()->json([
        'message' => 'Mot de passe réinitialisé avec succès.'
    ], 200);
}


    public function register(Request $request)
    {
        // Validation des données
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
                'message' => 'Validation failed'
            ], 422);
        }

        try {
            // Création de l'utilisateur
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => 'user'
            ]);

            // Création du token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'message' => 'User registered successfully',
                'user' => $user,
                'token' => $token
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ], 200);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        return $status === Password::RESET_LINK_SENT
            ? response()->json(['message' => __($status)])
            : response()->json(['message' => __($status)], 400);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));

                $user->save();

                event(new PasswordReset($user));
            }
        );

        return $status === Password::PASSWORD_RESET
            ? response()->json(['message' => __($status)])
            : response()->json(['message' => __($status)], 400);
    }

    public function resetPasswordWeb(Request $request)
{
    $request->validate([
        'token' => 'required',
        'email' => 'required|email',
        'password' => 'required|min:6|confirmed',
    ]);

    $status = Password::reset(
        $request->only('email', 'password', 'password_confirmation', 'token'),
        function ($user, $password) {
            $user->forceFill([
                'password' => Hash::make($password)
            ])->setRememberToken(Str::random(60));

            $user->save();

            event(new PasswordReset($user));
        }
    );

    return $status == Password::PASSWORD_RESET
        ? redirect()->back()->with('status', __($status))
        : back()->withErrors(['email' => [__($status)]]);
}
}