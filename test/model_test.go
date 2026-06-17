package main

import (
	"testing"

	"github.com/whisper-cpp-bindings/whisper-go/whisper"
)

func TestLoadingModel(t *testing.T) {
	model := whisper.LoadModel("hey")
	if model.GetString() != "hey" {
		t.Errorf("Failed loading Model!")
	}

	model = whisper.LoadModelForPlatform()
	if s := model.GetString(); s != "hey" {
		t.Logf("Success fully loaded model with platform: %s", s)
	}
}
