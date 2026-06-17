package whisper

import "github.com/whisper-cpp-bindings/whisper-go/whisper/internal"

// dummy model type
type Model struct {
	string
}

// dummy LoadModel function
func LoadModelForPlatform() *Model {
	return new(Model{internal.Platform})
}

func (m *Model) GetString() string {
	return m.string
}

// dummy LoadModel function
func LoadModel(s string) *Model {
	return new(Model{s})
}
