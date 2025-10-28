package curation.policies

import rego.v1

release := input.data

release_evidence := [evidence | some evidence in release.evidenceConnection[_]]

artifact_evidence := [evidence.node.evidenceConnection[_][_] | some evidence in release.artifactsConnection[_]]

build_evidence := [evidence.evidenceConnection[_][_] | some evidence in release.fromBuilds[_]]

all_layers_evidences := array.concat(release_evidence, array.concat(artifact_evidence, build_evidence))

default exists := false

default has_approved_key := []

has_approved_key := [evidence | 
    some evidence in artifact_evidence
    evidence.node.is_approved == true
]

exists if {
	count(has_approved_key) > 0
}

allow := {
	"should_allow": exists
}