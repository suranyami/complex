
defprotocol Complex.Conversion do
  def to_complex(arg1, arg2\\0)
end


defimpl Complex.Conversion, for: [Integer, Float] do
  def to_complex(r, i) do
     Complex.Number.new(real: r, i: i)
  end
end

defimpl Complex.Conversion, for: Complex.Number do
  def to_complex(arg1, _) do
    arg1
  end
end


defmodule Complex do
  @typep complex :: Complex.Number
  @typep real_complex :: number | Complex.Number

  defrecord Number, real: 0.0, i: 0.0 do
    record_type real: number, i: number
  end
  @moduledoc """
    A naive implementation of complex numbers.
  """

  @doc """
  Creates a new complex number
  ## Examples

      iex> inspect Complex.new(1, 2)
      "1+2i"
  """
  @spec new(number, number) :: complex
  def new(r, i) when is_number(r) and is_number(i) do
    Complex.Conversion.to_complex(r, i)
  end

  @doc """
  Convenience method to create based on one unknown number

  ## Example

      iex> inspect Complex.new(Complex.new(2,0))
      "2+0i"
  
      iex> inspect Complex.new(2)
      "2+0i"
  """
  @spec new(real_complex) :: complex
  def new(number_or_complex) do
    Complex.Conversion.to_complex(number_or_complex)
  end

  @doc """
  Checks if a number is complex
  ## Examples

      iex> Complex.is_complex(Complex.new(1,2))
      true
  
      iex> Complex.is_complex(3)
      true
  
      iex> Complex.is_complex()
      false
  """
  defmacrop is_complex(x) do
    if __CALLER__.in_guard? do
      quote do
        is_record(unquote(x), Complex.Number) or is_number(unquote(x))
      end
    else
      quote bind_quoted: [x: x] do
        is_record(x, Complex.Number) or is_number(x)
      end
    end
  end


  @doc """
  Creates a new complex number given polar coordinates
   ## Examples

      iex> inspect Complex.from_polar(4, 0)
      "4.0+0.0i"

      iex> inspect Complex.from_polar(4, :math.pi/2)
      "0.0+4.0i"

      iex> inspect Complex.from_polar(3, :math.pi)
      "-3.0+0.0i"
  """
  @spec from_polar(number, number) :: complex
  def from_polar(r, angle) do #when is_numeric(r) and is_numeric(angle) do
    real = r * round(:math.cos(angle), 1.0e-10)
    i = r * round(:math.sin(angle), 1.0e-10)
    new(real, i)
  end


  @doc """
  Returns the real part of the complex number.

  ## Examples

      iex> Complex.real(Complex.new(1, 2))
      1

      iex> Complex.real(Complex.new(0, 2))
      0

      iex> Complex.real(3)
      3
  """
  @spec real(real_complex) :: number
  def real(complex) when is_record(complex, Number) do
    complex.real
  end

  def real(number) when is_number(number) do
    number
  end

  @doc """
  Returns the imaginary part of the complex number.

  ## Examples

      iex> Complex.imag(Complex.new(1, 2))
      2

      iex> Complex.imag(Complex.new(2, 0))
      0

      iex> Complex.imag(3)
      0
  """
  def imag(complex) when is_record(complex, Number)  do
    complex.i
  end

  def imag(number) when is_number(number) do
    0
  end

  @doc """
  Convenience function to return imaginary number
  """
  def i(complex) do
    imag(complex)
  end

  @doc """
  Returns the conjugate of the complex number
   ## Examples

      iex> inspect Complex.conj(Complex.new(1, 0))
      "1+0i"

      iex> Complex.conj(3)
      Complex.Number[real: 3, i: 0]
  """
  @spec real(real_complex) :: number
  def conj(complex) when is_record(complex, Number) do
    new(complex.real, -complex.i)
  end

  def conj(number) when is_number(number) do
    new(number)
  end



  @doc """
  Adds two complex numbers
   ## Examples

      iex> inspect Complex.add(Complex.new(1,2), Complex.new(1,2))
      "2+4i"

      iex> inspect Complex.add(Complex.new(1,2), 5)
      "6+2i"

      iex> inspect Complex.add(1,3)
      "4+0i"
  """
  def add(x1, x2) when is_complex(x1) and is_complex(x2) do
    c1 = new(x1)
    c2 = new(x2)
    new(c1.real + c2.real, c1.i + c2.i)
  end

  @doc """
  Substracts two complex numbers
   ## Examples

      iex> inspect Complex.sub(Complex.new(1, 2), Complex.new(1, 2))
      "0+0i"

      iex> inspect Complex.sub(Complex.new(1, 2), 5)
      "-4+2i"

      iex> inspect Complex.sub(1,3)
      "-2+0i"
  """
  def sub(x1, x2) when is_complex(x1) and is_complex(x2) do
    c1 = new(x1)
    c2 = new(x2)
    new(c1.real - c2.real, c1.i - c2.i)
  end

  @doc """
  multiplies two complex numbers
   ## Examples

      iex> inspect Complex.mult(Complex.new(1,2), Complex.new(1,2))
      "-3+4i"

      iex> inspect Complex.mult(Complex.new(1,2), 5)
      "5+10i"

      iex> inspect Complex.mult(1,3)
      "3+0i"
  """
  def mult(x1, x2) when is_complex(x1) and is_complex(x2) do
    c1 = new(x1)
    c2 = new(x2)
    real = (c1.real * c2.real) - (c1.i * c2.i)
    img = (c1.real * c2.i) + (c1.i * c2.real)
    new(real, img)
  end

  @doc """
  divides two complex numbers
   ## Examples

      iex> inspect Complex.div(Complex.new(1,2), Complex.new(1,2))
      "1.0+0.0i"

      iex> inspect Complex.div(Complex.new(1,2), 5)
      "0.2+0.4i"

      iex> inspect Complex.div(3,1)
      "3.0+0.0i"

      iex> inspect Complex.div(6,Complex.new(3,1))
      "1.8-0.6i"

  """
  def div(x1, x2) when is_complex(x1) and is_complex(x2) do
    num = new(x1)
    den = new(x2)
    conjunction = conj(den)
    result_num = mult(num, conjunction)
    result_den = mult(den, conjunction)

    real = result_num.real / result_den.real
    img = result_num.i / result_den.real
    new(real, img)
  end

  @doc """
  calculate the size of the polar representation of a complex number
  ## Examples

      iex> Complex.size(Complex.new(3,4))
      5.0

      iex> Complex.size(Complex.new(3,-4))
      5.0

      iex> Complex.size(5)
      5.0
  """

  def size(x1) when is_complex(x1) do
    c1 = new(x1)
    :math.sqrt(c1.real * c1.real + c1.i * c1.i)
  end


  @doc """
  Returns the number when normalized as a vector with size 1
  ## Examples

      iex> inspect Complex.normalize(Complex.new(3,4))
      "0.6+0.8i"

      iex> inspect Complex.normalize(Complex.new(3,-4))
      "0.6-0.8i"

      iex> inspect Complex.normalize(5)
      "1.0+0.0i"
  """
  def normalize(x1) when is_complex(x1) do
    c1 = new(x1)
    size = Complex.size(x1)
    new(c1.real/size, c1.i/size)
  end

  @doc """
  Calculate the argument of the polar representation of a complex number.

   ## Examples
      iex> Complex.argument(Complex.new(3,3)) / :math.pi
      0.25

      iex> Complex.argument(Complex.new(3,-3)) / :math.pi
      -0.25

      iex> Complex.argument(5)
      0
  """
  def argument(x1) do
    c1 = new(x1)
    if c1.i == 0 do
      0
    else
      c1 = normalize(x1)
      :math.atan(c1.real/c1.i)
    end
  end


  @doc """
  calculate the power of a complex number
   ## Examples

      iex> inspect Complex.power(Complex.new(3, 3), 2)
      "0.0+18.0i"

      iex> inspect Complex.power(Complex.new(3, 3), 0)
      "1.0+0.0i"

      iex> inspect Complex.power(Complex.new(4, 4), -2)
      "0.0-0.03125i"

      iex> inspect Complex.power(5, 2)
      "25.0+0.0i"

  """
  def power(x1, power) when is_complex(x1) and is_number(power) do
    r = Complex.size(x1)
    angle = argument(x1)
    power_r = round(:math.pow(r, power), 1.0e-10)
    power_angle = round(angle * power, 1.0e-10)
    from_polar(power_r, power_angle)
  end


  @doc """
  calculate a complex number to the power of a complex number
     ## Examples

  """
  def power(x, y) when is_complex(x) and is_complex(y) do
    
  end

  @doc """
  Rounds a number to a given resolution.

   ## Examples

      iex> Complex.round(3.1415912, 1.0e-4)
      3.1416

      iex> Complex.round(0.25, 1.0e-4)
      0.25

      iex> Complex.round(3.14158, 1.0e4)
      0.0

      iex> Complex.round(3.14158, 1)
      3

  """
  def round(number, resolution) when is_number(number) and is_number(resolution) do
    round(number / resolution) * resolution
  end
end

defimpl Inspect, for: Complex.Number do
  @doc """
  Represents a complex number as a string

   ## Examples
       iex> inspect(Complex.new(1, 2))
       "1+2i"

       iex> inspect(Complex.new(1, -2))
       "1-2i"

       iex> inspect(Complex.new(-1, -2))
       "-1-2i"
   """

  def inspect(complex, _) do
    "#{Complex.real(complex)}#{inspect_imaginary(complex)}i"
  end

  defp inspect_imaginary(complex) do
    if Complex.i(complex) < 0 do
      Complex.i(complex)
    else
      "+#{Complex.i(complex)}"
    end
  end
end
