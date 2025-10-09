extends GutTest

func test_assert_block_sides_flip_correctly():
    assert_eq(Global.BlockSide.LEFT, ~Global.BlockSide.RIGHT)
    assert_eq(Global.BlockSide.TOP, ~Global.BlockSide.BOTTOM)
    assert_eq(Global.BlockSide.FRONT, ~Global.BlockSide.BACK)

enum TestEnum {
    FOO = 0,
    BAR = 1,
}
func test_assert_enum_keys_can_be_grabbed_by_value():
    assert_eq(Global.get_enum_key(0, TestEnum), "FOO")
    assert_eq(Global.get_enum_key(1, TestEnum), "BAR")

func test_assert_block_side_names():
    assert_eq(Global.get_side_name(Global.BlockSide.LEFT), "LEFT")