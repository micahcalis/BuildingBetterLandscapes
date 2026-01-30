#ifndef FLOW_INCLUDED
#define FLOW_INCLUDED

struct Flow
{
    float waterFlow;
    float acidMass;
};

Flow CreateFlow(float waterAmount, float acidConcentration)
{
    Flow flow;
    flow.waterFlow = waterAmount;
    flow.acidMass = waterAmount * acidConcentration;
    return flow;
}

Flow GetBaseFlow(KarstMaterial base)
{
    Flow flow;
    flow.waterFlow = base.waterAmount;
    flow.acidMass = base.waterAmount * base.acidConcentration;
    return flow;
}

Flow AddFlows(Flow flowA, Flow flowB)
{
    Flow result;
    result.waterFlow = flowA.waterFlow + flowB.waterFlow;
    result.acidMass = flowA.acidMass + flowB.acidMass;
    return result;
}

Flow SubtractFlows(Flow flowA, Flow flowB)
{
    Flow result;
    result.waterFlow = flowA.waterFlow - flowB.waterFlow;
    result.acidMass = flowA.acidMass - flowB.acidMass;
    return result;
}

Flow CreatePartialFlow(Flow source, float waterAmountToTake)
{
    Flow result;
    
    if (source.waterFlow <= 0.0001f)
    {
        result.waterFlow = 0;
        result.acidMass = 0;
        return result;
    }
    
    float concentration = source.acidMass / source.waterFlow;
    
    result.waterFlow = waterAmountToTake;
    result.acidMass = waterAmountToTake * concentration;
    
    return result;
}

float ResolveAcidMass(float waterAmount, float acidMass)
{
    float acidConcentration;
    if (waterAmount > 1e-4)
    {
        acidConcentration = acidMass / waterAmount;
        acidConcentration = saturate(acidConcentration);
    }
    else 
    {
        acidConcentration = 0.0f;
    }

    return acidConcentration;
}

#endif
