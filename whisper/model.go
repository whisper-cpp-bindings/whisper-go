package whisper

// dummy model type
type Model struct {
	string
}

func (m *Model) GetString() string {
	return m.string
}

// dummy LoadModel function
func LoadModel(s string) *Model {
	return new(Model{s})
}
