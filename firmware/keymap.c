#include QMK_KEYBOARD_H

// Layer definitions
enum layers {
    _BASE = 0,
};

// XIAO RP2040 GPIO to QMK pin mapping:
// D0=GP26, D1=GP27, D2=GP28, D3=GP29, D4=GP6, D5=GP7
// D6=GP0, D7=GP1, D8=GP2, D9=GP3, D10=GP4

// Custom keycodes for Claude Code actions
enum custom_keycodes {
    CC_ALLOW_ONCE = SAFE_RANGE,  // Sends 'y' (accept once)
    CC_ALLOW_ALWAYS,              // Sends 'a' (always allow)
    CC_REJECT,                    // Sends 'n' (reject)
    CC_MIC,                       // Toggles macOS dictation (Fn+Fn)
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /*
     * ,-------.          ,-------.
     * | ESC   |          | TAB   |
     * `-------'          `-------'
     *             ,-------.
     *    ALLOW    |  UP   |    ALLOW
     *    ONCE     `-------'   ALWAYS
     *          ,---+---+---.
     *          | < | v | > |
     *          `---+---+---'
     *      ,---+===+===+===+---.
     *      |REJ|  ENTER    |MIC|
     *      `---+===========+---'
     */
    [_BASE] = LAYOUT(
        KC_ESC,         KC_UP,          KC_TAB,
        CC_ALLOW_ONCE,  KC_LEFT,  KC_DOWN,  KC_RIGHT,  CC_ALLOW_ALWAYS,
        CC_REJECT,      KC_ENT,         CC_MIC
    ),
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case CC_ALLOW_ONCE:
            if (record->event.pressed) {
                tap_code(KC_Y);  // 'y' = accept permission once
            }
            return false;

        case CC_ALLOW_ALWAYS:
            if (record->event.pressed) {
                tap_code(KC_A);  // 'a' = always allow
            }
            return false;

        case CC_REJECT:
            if (record->event.pressed) {
                tap_code(KC_N);  // 'n' = reject permission
            }
            return false;

        case CC_MIC:
            if (record->event.pressed) {
                // Toggle macOS dictation: press Globe/Fn key twice
                // On RP2040, this sends the dictation shortcut
                tap_code(KC_F5);  // Fallback: F5 as placeholder
                // For macOS dictation, remap in System Settings > Keyboard > Dictation
            }
            return false;
    }
    return true;
}
