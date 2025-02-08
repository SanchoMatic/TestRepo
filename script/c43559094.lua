-- Unleash the Black Magic!
local s,id=GetID(43559094)
-- List the names of referenced cards
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- Activate effect if you control "Dark Magician"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Set 1 Spell/Trap from GY or banishment that mentions "Dark Magician"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,nil)
end

function s.costfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,99,nil)
    local spell_count=g:FilterCount(Card.IsType,nil,TYPE_SPELL)
    local trap_count=g:FilterCount(Card.IsType,nil,TYPE_TRAP)
    e:SetLabel(spell_count,trap_count)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local spell_count,trap_count=e:GetLabel()
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,spell_count*400)
    if trap_count>0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,trap_count)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local spell_count,trap_count=e:GetLabel()
    if spell_count>0 then
        Duel.Damage(1-tp,spell_count*400,REASON_EFFECT)
    end
    if trap_count>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,trap_count,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end
end

function s.setfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and Card.ListsCode(c,CARD_DARK_MAGICIAN) and not c:IsCode(id) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end