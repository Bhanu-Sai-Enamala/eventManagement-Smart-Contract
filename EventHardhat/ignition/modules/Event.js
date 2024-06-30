const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const eventfactoryModule = buildModule("EventFactoryModule",  (m) => {
  const eventFactory =  m.contract("EventFactory");
  return {
    eventFactory,
  };
});

module.exports = eventfactoryModule;