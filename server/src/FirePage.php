<?
class FirePage extends Page {
    public function run() {
        if (
            !array_key_exists('token', $this->data) ||
            !array_key_exists('angle', $this->data) ||
            !array_key_exists('power', $this->data)
        ) {
            return;
        }

        $this->result = [
            'success' => true
        ];
    }
}