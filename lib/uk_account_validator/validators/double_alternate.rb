module UkAccountValidator
  module Validators
    # Perform validation for sort codes with MOD10
    class DoubleAlternate < BaseValidator
      def modulus
        10
      end

      def valid?
        test_string = @sort_code + @account_number

        test_digits = test_string.split(//).map(&:to_i)

        total = applying_exceptions(test_digits) do
          # Apply weights
          weighted_test_digits = NUMBER_INDEX.map do |weight, index|
            @modulus_weight.send(weight) * test_digits[index]
          end

          # Split into individual digits by concating then splitting again.
          weighted_test_digits = weighted_test_digits.join.split(//).map(&:to_i)

          # Now sum
          weighted_test_digits.inject(:+)
        end

        case @modulus_weight.exception
        when '4'
          return apply_exception_4(total, test_digits)
        when '5'
          return apply_exception_5(total, test_digits, :h)
        end

        total % modulus == 0
      end
    end
  end
end
