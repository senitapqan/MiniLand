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

  def create_certificate(conn, unsafe_params) do
    with {:ok, params} <- CreateCertificateContract.conform(unsafe_params) do
      certificate = Certificates.create_new_certificate(params)

      conn
      |> put_status(:created)
      |> json(certificate.id)
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

  def use_certificate(conn, unsafe_params) do
    with {:ok, params} <- UseCertificateContract.conform(unsafe_params) do
      user_id = conn.assigns.user_id
      attrs = Map.put(params.attrs, :user_id, user_id)

      {:ok, _certificate} = Certificates.use_certificate!(params.certificate_id)
      order = Orders.create_new_order(attrs)

      json(conn, %{order_id: order.id})
    end
  end

  def get_certificates(conn, _params) do
    certificates = Certificates.pull_certificates()
    json(conn, certificates)
  end

  def search_certificate(conn, %{phone: phone}) do
    certificate = Certificates.search_certificate(phone)
    json(conn, certificate)
  end
end
