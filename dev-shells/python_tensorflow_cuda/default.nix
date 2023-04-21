{ pkgs ? import <nixpkgs> {} }:
let
  python = let
    packageOverrides = self: super: {
      tensorflow-datasets = super.tensorflow-datasets.overridePythonAttrs(old: rec {
        propagatedBuildInputs = old.propagatedBuildInputs ++ (with super; [
          absl-py
          click
          etils
          psutil
          toml
          wrapt
        ]);
        nativeCheckInputs = old.nativeCheckInputs ++ (with super; [
          datasets
          pyyaml
        ]);
        disabledTestPaths = builtins.filter (p:
        p != "tensorflow_datasets/audio/groove_test.py" && p != "tensorflow_datasets/audio/nsynth_test.py")
        old.disabledTestPaths ++ [
          "tensorflow_datasets/import_without_tf_test.py"
          "tensorflow_datasets/core/registered_test.py"
          "tensorflow_datasets/core/dataset_utils_test.py"
          "tensorflow_datasets/core/dataset_builders/conll/conllu_dataset_builder_test.py"
          "tensorflow_datasets/core/features/audio_feature_test.py"
          "tensorflow_datasets/core/features/sequence_feature_test.py"
          "tensorflow_datasets/datasets/groove/groove_dataset_builder_test.py"
          "tensorflow_datasets/datasets/universal_dependencies/universal_dependencies_dataset_builder_test.py"
          "tensorflow_datasets/datasets/xtreme_pos/xtreme_pos_dataset_builder_test.py"
          "tensorflow_datasets/datasets/nsynth/nsynth_dataset_builder_test.py"
        ];
      });
    };
  in pkgs.python39.override {inherit packageOverrides; self = python;};

  my-packages = p: with p; [
    tensorflowWithCuda
    tensorflow-datasets
    keras
    matplotlib
    tkinter
  ];
  my-python = python.withPackages my-packages;
in my-python.env
