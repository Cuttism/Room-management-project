package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Utility class for one-way password hashing and verification using PBKDF2WithHmacSHA256.
 * Format stored in DB: pbkdf2$iterations$base64Salt$base64Hash
 */
public final class PasswordUtil {
    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final String PREFIX = "pbkdf2$";
    private static final int ITERATIONS = 65536;
    private static final int SALT_LENGTH = 16;
    private static final int KEY_LENGTH = 256;

    private PasswordUtil() {
    }

    /**
     * Hash a raw password with a random 16-byte cryptographic salt.
     */
    public static String hashPassword(String rawPassword) {
        if (rawPassword == null || rawPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        // Prevent double-hashing if already hashed
        if (isHashed(rawPassword)) {
            return rawPassword;
        }

        byte[] salt = new byte[SALT_LENGTH];
        new SecureRandom().nextBytes(salt);
        byte[] hash = pbkdf2(rawPassword.toCharArray(), salt, ITERATIONS, KEY_LENGTH);

        String saltB64 = Base64.getEncoder().encodeToString(salt);
        String hashB64 = Base64.getEncoder().encodeToString(hash);
        return PREFIX + ITERATIONS + "$" + saltB64 + "$" + hashB64;
    }

    /**
     * Verify a raw password against a stored password hash.
     * Supports both PBKDF2 hashes and legacy plain-text passwords for backward compatibility.
     */
    public static boolean verifyPassword(String rawPassword, String storedPassword) {
        if (rawPassword == null || storedPassword == null) {
            return false;
        }
        if (!isHashed(storedPassword)) {
            return rawPassword.equals(storedPassword);
        }

        String[] parts = storedPassword.split("\\$");
        if (parts.length != 4) {
            return false;
        }

        try {
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expectedHash = Base64.getDecoder().decode(parts[3]);

            byte[] actualHash = pbkdf2(rawPassword.toCharArray(), salt, iterations, expectedHash.length * 8);
            return MessageDigest.isEqual(expectedHash, actualHash);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Check whether a stored password string is already in PBKDF2 hash format.
     */
    public static boolean isHashed(String storedPassword) {
        return storedPassword != null && storedPassword.startsWith(PREFIX);
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Error hashing password with " + ALGORITHM, e);
        }
    }

    /**
     * CLI utility to migrate any unhashed plain-text passwords in the database to PBKDF2 hashes.
     */
    public static void main(String[] args) {
        dal.UserDAO userDAO = new dal.UserDAO();
        for (model.User u : userDAO.getAllUsers()) {
            if (!isHashed(u.getPassword())) {
                userDAO.updateProfile(u.getUserId(), u.getFullName(), u.getPhone(), u.getPassword());
            }
        }
        System.out.println("Sample hash for 123456: " + hashPassword("123456"));
    }
}
