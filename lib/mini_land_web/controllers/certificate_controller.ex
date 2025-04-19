defmodule MiniLandWeb.CertificateController do
  alias MiniLand.Certificates
  alias MiniLand.Orders

  use MiniLandWeb, :controller

  defmodule CreateCertificateContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:buyer_full_name) => string(:filled?),
        required(:buyer_phone) => string(:filled?),
        required(:receiver_full_name) => string(:filled?),
        required(:receiver_phone) => string(:filled?),
        required(:promotion_name) => string(:filled?)
      }
    end
  end

  # tested
  def create_certificate(conn, unsafe_params) do
    with {:ok, params} <- CreateCertificateContract.conform(unsafe_params) do
      render_response(conn, Certificates.create_new_certificate(params))
    end
  end

  defmodule UseCertificateContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:certificate_id) => integer(:filled?),
        required(:attrs) => %{
          required(:order_type) => string(:filled?),
          required(:promotion_name) => string(:filled?),
          required(:child_full_name) => string(:filled?),
          required(:child_age) => integer(),
          required(:parent_full_name) => string(:filled?),
          required(:parent_phone) => string(:filled?)
        }
      }
    end
  end

  # tested
  def use_certificate(conn, unsafe_params) do
    with {:ok, params} <- UseCertificateContract.conform(unsafe_params) do
      user_id = conn.assigns.user_id
      attrs = Map.put(params.attrs, :user_id, user_id)

      {:ok, _certificate} = Certificates.use_certificate!(params.certificate_id)
      render_response(conn, Orders.create_new_order(attrs))
    end
  end

  # tested
  def get_certificates(conn, _params) do
    certificates = Certificates.pull_certificates()
    render_response(conn, {:ok, certificates})
  end

  # tested
  def search_certificate(conn, %{"phone" => phone}) do
    render_response(conn, Certificates.search_certificate(phone))
  end

  # tested
  def delete_certificate(conn, _params) do
    certificate_id = conn.params["id"]
    render_response(conn, Certificates.delete_certificate(certificate_id))
  end

  defp render_response(conn, response) do
    case response do
      {:ok, data} ->
        conn
        |> put_status(200)
        |> json(%{data: data})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{msg: "Certificate not found"})

      {:error, _error} ->
        conn
        |> put_status(500)
        |> json(%{msg: "Some unknown internal server error"})
    end
  end
end
