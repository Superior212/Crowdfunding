import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CrowdModule = buildModule("CrowdModule", (m) => {
  const CrowdFunding = m.contract("CrowdFunding", [], {});

  return { CrowdFunding };
});

export default CrowdModule;
