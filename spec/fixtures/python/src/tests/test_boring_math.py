# To re-generate the .coverage file:
#   coverage run -m pytest
# This requires two Python libraries:
#   pip install coverage
#   pip install pytest

from unittest import TestCase

from src import boring_math

class TestBoringMath(TestCase):
    def test_fib_0(self):
        result = boring_math.fib(0)
        self.assertEqual(result, 1)
