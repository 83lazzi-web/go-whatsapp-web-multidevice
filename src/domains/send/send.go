package send

type GenericResponse struct {
	MessageID string `json:"message_id"`
	Status    string `json:"status"`
	Phone     string `json:"phone,omitempty"`
}

type VerifyNumberResponse struct {
	Phone  string `json:"phone"`
	Valid  bool   `json:"valid"`
	Status string `json:"status"`
}
