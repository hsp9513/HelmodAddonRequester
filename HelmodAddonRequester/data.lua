local request_blueprint = table.deepcopy(data.raw["blueprint"]["blueprint"])

request_blueprint.name = 'helmod-requester-blueprint'
request_blueprint.localised_name = {'item-name.helmod-request-blueprint'}
request_blueprint.localised_description=''
request_blueprint.stackable = false

request_blueprint.flags = {"only-in-cursor", "spawnable"}
request_blueprint.icons={
  {
    icon = "__base__/graphics/icons/blueprint.png"
  },
  {
    icon = "__base__/graphics/icons/constant-combinator.png"
  }
}

data:extend{request_blueprint}
