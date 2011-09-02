
class VectorClock

  def initialize
    @vector = {}
  end

  def [](client)
    check_client(client)
    return @vector[client]
  end

  def initialize_copy(source)
    super
    @vector = @vector.dup
  end

  #define ordering based on maximum clock value in vector
  #this is somewhat arbitrary, but we need a tiebreaker and this seems reasonable
  def <=>(ov)
    return @vector.values.max <=> ov.get_max_clock
  end

  #does this vector "happen before" vector v?
  def happens_before(v)
    #need to ensure there is at least one element that is strictly less-than
    strictly_less = false

    for client in (v.get_clients+self.get_clients).uniq
      if (!@vector.has_key?(client) || @vector[client] < v[client])
        strictly_less = true
      elsif @vector[client] > v[client]
        return false
      end
    end
    
    return strictly_less
  end

  def increment(client)
    check_client(client)
    @vector[client] += 1
  end

  def merge(v2)
    for client in v2.get_clients
      if !@vector.has_key?(client) || @vector[client] < v2[client]
        @vector[client] = v2[client]
      end
    end
  end

  private
  def check_client(client)
    if !@vector.has_key?(client):
        @vector[client] = 0
    end
  end

  protected
  def get_clients
    return @vector.keys
  end

  protected
  def get_max_clock
    return @vector.values.max
  end

end
