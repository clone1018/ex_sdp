defmodule Membrane.Protocol.SDP.Origin do
  @moduledoc """
  This module represents Origin field of SDP that represents
  originator of the session.

  If username is set to `-` the originating host does not support the concept of user IDs.

  For more details please see [RFC4566 Section 5.2](https://tools.ietf.org/html/rfc4566#section-5.2)
  """
  use Bunch

  defstruct [
    :username,
    :session_id,
    :session_version,
    :network_type,
    :address_type,
    :unicast_address
  ]

  @type t :: %__MODULE__{
          username: binary(),
          session_id: binary(),
          session_version: binary(),
          network_type: binary(),
          address_type: binary(),
          unicast_address: :inet.ip_address()
        }

  @spec parse(binary()) ::
          {:ok, t()} | {:error, :einval | :invalid_origin | {:not_supported_addr_type, binary()}}
  def parse(origin) do
    withl parse:
            [username, sess_id, sess_version, nettype, addrtype, unicast_address] <-
              String.split(origin, " "),
          valid_addr_type: type when type in ["IP4", "IP6"] <- addrtype do
      address =
        case :inet.parse_address(unicast_address |> to_charlist()) do
          {:ok, address} -> address
          {:error, :einval} -> unicast_address
        end

      %__MODULE__{
        username: username,
        session_id: sess_id,
        session_version: sess_version,
        network_type: nettype,
        address_type: addrtype,
        unicast_address: address
      }
      ~> {:ok, &1}
    else
      parse: _ -> {:error, :invalid_origin}
      valid_addr_type: type -> {:error, {:not_supported_addr_type, type}}
      addr_parse: {:error, _} = error -> error
    end
  end
end
