import React from "react";

const TestComponentJ1 = ({ prop1, prop2 }) => {};

const TestComponentJ2 = ({ prop1, prop2 }) => {
  return <TestComponentJ1 />;
};

export default TestComponentJ2;
