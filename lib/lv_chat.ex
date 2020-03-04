defmodule LvChat do
  use GenServer
  
  @ets_config [:set, :named_table, :public, {:read_concurrency, true}, {:write_concurrency, true}]

  @name __MODULE__

  def match(gender, list) do
    list
    |> Enum.uniq()
    |> build_query(gender)
    |> query_ets(2)
    |> case do
      tup when is_tuple(tup) ->
        tup
        |> Tuple.to_list()
        |> List.first()
        |> List.flatten()
      _ -> []
    end
  end

  def subscribe(pid, gender) do
    :ets.insert(:matching, {pid, gender})
  end

  def unsubscribe(pid) do
    :ets.delete(:matching, pid)
  end

  defp query_ets(query, limit) do
    :ets.select(:matching, query, limit)
  end

  defp build_query(list, gender) do
    gender_match = {:"/=", :"$2", gender}
    pid_match = 
      list
      |> Enum.reduce({:orelse}, fn pid, acc -> Tuple.append(acc, {:"=:=", :"$1", pid}) end) 
    
    [
      {{:"$1", :"$2"},
       [
         {:andalso, 
            {:not, 
              pid_match           
            },
          gender_match
          }
       ], [:"$1"]} 
    ]
  end


  #####  DB SERVER #####

  def start_link(_), do: GenServer.start_link(@name, :ok, name: @name)

  @impl true
  def init(_) do
    {:ok, :ets.new(:matching, @ets_config)}
  end
end
