package main

import "core:testing"

@(test)
label_batch_contract :: proc(t: ^testing.T) {
    testing.expect_value(t, validate_labels(nil), Label_Result{.No_Labels, -1})
    labels := [?]string{"sound", "image"}
    testing.expect_value(t, validate_labels(labels[:]), Label_Result{.Ok, -1})
    empty := [?]string{"sound", "", "sound"}
    testing.expect_value(t, validate_labels(empty[:]), Label_Result{.Empty_Label, 1})
    duplicate := [?]string{"sound", "image", "sound", ""}
    testing.expect_value(t, validate_labels(duplicate[:]), Label_Result{.Duplicate_Label, 2})
    case_variant := [?]string{"asset", "Asset"}
    testing.expect_value(t, validate_labels(case_variant[:]), Label_Result{.Ok, -1})
}
