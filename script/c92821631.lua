-- Shaman with Eyes of Blue
function c92821631.initial_effect(c)
    -- Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(c92821631.spcon)
    c:RegisterEffect(e1)
    
    -- Add Spell/Trap mentioning "Blue-Eyes White Dragon"
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(c92821631.thtg)
    e2:SetOperation(c92821631.thop)
    c:RegisterEffect(e2)
    
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    
    -- Register End Phase search effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetOperation(c92821631.regop)
    c:RegisterEffect(e4)
    
    -- Reset search effect flag
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_TURN_END)
    e5:SetOperation(c92821631.resetsearch)
    Duel.RegisterEffect(e5,0)
end

-- Manage search effect usage
c92821631.SearchEffect_Used = false
c92821631.SearchEffect_Activated = false

-- Special summon condition
function c92821631.spfilter(c)
    return c:IsFaceup() and c:ListsCode(89631139) -- "Blue-Eyes White Dragon"
end

function c92821631.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(c92821631.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end

-- Filter for Spells/Traps mentioning "Blue-Eyes White Dragon"
function c92821631.thfilter(c)
    return c:IsAbleToHand() and c:ListsCode(89631139) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end

-- Search Effect - Deck and GY
function c92821631.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not c92821631.SearchEffect_Activated and not c92821631.SearchEffect_Used and Duel.IsExistingMatchingCard(c92821631.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c92821631.thop(e,tp,eg,ep,ev,re,r,rp)
    c92821631.SearchEffect_Used = true
    c92821631.SearchEffect_Activated = true
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c92821631.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Reset the search effect flag at the end of the turn
function c92821631.resetsearch()
    c92821631.SearchEffect_Used = false
    c92821631.SearchEffect_Activated = false
end

-- Register End Phase search effect
function c92821631.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Search for a Level 4 or lower LIGHT Tuner during the End Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(92821631,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1)
    e1:SetTarget(c92821631.tgt2)
    e1:SetOperation(c92821631.op2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

-- Filter for Level 4 or lower LIGHT Tuner monsters
function c92821631.tnfilter(c)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)
end

-- Target for Tuner search during End Phase
function c92821631.tgt2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not c92821631.SearchEffect_Activated and Duel.IsExistingMatchingCard(c92821631.tnfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- Operation for Tuner search during End Phase
function c92821631.op2(e,tp,eg,ep,ev,re,r,rp)
    c92821631.SearchEffect_Activated = true
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c92821631.tnfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end